defmodule Xeon.Processors do
  require Logger
  alias Xeon.{Repo, Processor, ProcessorScore}
  @url "https://browser.geekbench.com/processor-benchmarks"
  @cache_dir "/Users/achilles/.cache"

  def create(params) do
    Processor.new(params) |> Repo.insert()
  end

  def import_processors() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://dev.local:27017/xeon")
    cursor = Mongo.find(conn, "Processor", %{"attributes.0" => %{"$exists" => true}})
    entities = Enum.map(cursor, &parse_processor/1)

    entities
    |> Enum.group_by(& &1.name)
    |> Enum.map(fn {k, v} -> {k, length(v)} end)
    |> Enum.filter(fn {_, v} -> v > 1 end)

    Repo.insert_all(Processor, entities, on_conflict: :replace_all, conflict_target: [:name, :sub])
  end

  defp parse_processor(%{
         "title" => name,
         "subtitle" => sub,
         "url" => url,
         "attributes" => attributes
       }) do
    code = get_value(attributes, "Essentials", "Processor Number")
    collection_name = get_value(attributes, "Essentials", "Product Collection")
    launch_date = get_value(attributes, "Essentials", "Launch Date") |> parse_launch_date()
    status = get_value(attributes, "Essentials", "Status")
    cache_size = get_value(attributes, "CPU Specifications", "Cache") |> parse_cache_size()
    lithography = get_value(attributes, "Essentials", "Lithography")
    socket = get_value(attributes, "Package Specifications", "Sockets Supported")

    memory_types =
      get_value(attributes, "Memory Specifications", "Memory Types") |> parse_memory_types()

    case_temperature =
      get_value(attributes, "Package Specifications", "TCASE") |> parse_temperuture()

    cores = get_value(attributes, "CPU Specifications", "Total Cores") |> parse_integer()

    threads = get_value(attributes, "CPU Specifications", "Total Threads") |> parse_integer()

    base_frequency =
      get_value(attributes, "CPU Specifications", "Processor Base Frequency")
      |> parse_frequency()

    tdp = get_value(attributes, "CPU Specifications", "TDP") |> parse_decimal(" W")

    tdp_up_base_frequency =
      get_value(attributes, "CPU Specifications", "Configurable TDP-up Base Frequency")
      |> parse_frequency()

    tdp_up =
      get_value(attributes, "CPU Specifications", "Configurable TDP-up") |> parse_decimal(" W")

    tdp_down_base_frequency =
      get_value(attributes, "CPU Specifications", "Configurable TDP-down Base Frequency")
      |> parse_frequency()

    tdp_down =
      get_value(attributes, "CPU Specifications", "Configurable TDP-down") |> parse_decimal(" W")

    max_turbo_frequency =
      get_value(attributes, "CPU Specifications", "Max Turbo Frequency")
      |> parse_frequency()

    attributes =
      Enum.map(attributes, fn %{"group" => group, "items" => items} ->
        %Xeon.Processor.Attribute{
          group: group,
          items:
            Enum.map(
              items,
              &%Xeon.Processor.Attribute.AttributeItem{
                label: &1["label"],
                value: &1["value"]
              }
            )
        }
      end)

    %{
      code: code,
      name: name,
      sub: sub,
      url: url,
      collection_name: collection_name,
      launch_date: launch_date,
      status: status,
      socket: socket,
      case_temperature: case_temperature,
      lithography: lithography,
      cores: cores,
      threads: threads,
      base_frequency: base_frequency,
      max_turbo_frequency: max_turbo_frequency,
      tdp: tdp,
      tdp_up_base_frequency: tdp_up_base_frequency,
      tdp_up: tdp_up,
      tdp_down_base_frequency: tdp_down_base_frequency,
      tdp_down: tdp_down,
      cache_size: cache_size,
      memory_types: memory_types,
      attributes: attributes
    }
  end

  defp parse_memory_types(value) do
    value
    |> case do
      nil ->
        []

      v ->
        v
        |> String.split(",")
        |> Enum.map(&String.trim/1)
    end
  end

  defp parse_cache_size(value) do
    [cache_size | _] = value |> String.split(" ")
    Decimal.new(cache_size)
  end

  defp parse_launch_date(value) do
    [q, y] = value |> String.split("'")
    "20#{y}-#{q}"
  end

  defp parse_temperuture(nil) do
    nil
  end

  defp parse_temperuture(value) do
    case value do
      nil ->
        nil

      "." ->
        nil

      "" <> temp ->
        temp
        |> String.replace("°", "")
        |> String.replace("C", "")
        |> String.trim()
        |> Decimal.new()
    end
  end

  defp parse_integer(value, suffix \\ "")

  defp parse_integer(nil, _) do
    nil
  end

  defp parse_integer("" <> value, suffix) do
    String.replace(value, suffix, "") |> String.to_integer()
  end

  defp parse_frequency(nil) do
    nil
  end

  defp parse_frequency("" <> value) do
    cond do
      String.contains?(value, " MHz") -> parse_decimal(value, " MHz")
      String.contains?(value, " GHz") -> parse_decimal(value, " GHz") |> Decimal.mult(1000)
      true -> nil
    end
  end

  defp parse_decimal(nil, _) do
    nil
  end

  defp parse_decimal("" <> value, suffix) do
    String.replace(value, suffix, "") |> Decimal.new()
  end

  defp get_value(attributes, group, key) do
    attributes
    |> Enum.find(&(&1["group"] == group))
    |> case do
      nil ->
        nil

      %{"items" => field_values} ->
        field_values
        |> Enum.find(&(&1["label"] == key))
        |> case do
          nil -> nil
          %{"value" => value} -> value
        end
    end
  end

  def get_all_detail() do
    # processors = Repo.all(from p in Processor, where: is_nil(p.cores))
    processors = Repo.all(Processor)

    processors
    |> Task.async_stream(
      fn processor ->
        get_detail(processor)
        Logger.info("Get #{processor.name} detail")
      end,
      max_concurrency: 4,
      timeout: 30_000
    )
    |> Enum.into([])
  end

  def get_detail(processor = %{id: id, links: %{"geekbench" => url}}) do
    data = %{scores: %{single: single, multi: multi}} = get_processor(url)
    changeset = Processor.changeset(processor, data)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:processor, changeset)
    |> Ecto.Multi.insert(
      :processor_score,
      ProcessorScore.new(%{
        processor_id: id,
        test_name: "geekbench5",
        single: single,
        multi: multi
      }),
      on_conflict: :replace_all,
      conflict_target: [:processor_id, :test_name]
    )
    |> Repo.transaction()
  end

  def get_processors() do
    with {:ok, html} <- get_html(@url) do
      parse_processors(html)
    end
  end

  def get_processor(url) do
    with {:ok, html} <- get_html(url) do
      parse_processor(html)
    end
  end

  defp get_html(url = "https://browser.geekbench.com" <> path) do
    cache_path = Path.join(@cache_dir, "#{path}.html")

    if File.exists?(cache_path) do
      File.read(cache_path)
    else
      with {:ok, %{status: 200, body: html}} <-
             Finch.build(:get, url) |> Finch.request(MyFinch),
           :ok <- cache_path |> Path.dirname() |> File.mkdir_p(),
           :ok <- File.write(cache_path, html) do
        {:ok, html}
      end
    end
  end

  defp get_mhz(""), do: nil

  defp get_mhz(value) do
    value |> String.split(" ") |> List.first() |> String.to_integer()
  end

  defp parse_processor(html) do
    with {:ok, document} <- Floki.parse_document(html) do
      map =
        Floki.find(document, ".system-information tr")
        |> Enum.map(fn node ->
          label = node |> Floki.find(".name") |> Floki.text() |> String.trim()
          value = node |> Floki.find(".value") |> Floki.text() |> String.trim()
          {label, value}
        end)
        |> Enum.into(%{})

      name = Map.get(map, "Processor", "")
      frequency = Map.get(map, "Frequency", "") |> get_mhz()
      maximum_frequency = Map.get(map, "Maximum Frequency", "") |> get_mhz()
      cores = Map.get(map, "Cores", "") |> String.to_integer()
      threads = Map.get(map, "Threads", "") |> String.to_integer()
      tdp = Map.get(map, "TDP", "") |> get_mhz()
      gpu = Map.get(map, "GPU", "")
      family_code = Map.get(map, "Codename", "")
      socket = Map.get(map, "Package", "")

      [single_score, multi_score] =
        Floki.find(document, ".benchmark-box-wrapper .score")
        |> Enum.map(&(&1 |> Floki.text() |> String.to_integer()))

      %{
        name: name,
        frequency: frequency,
        maximum_frequency: maximum_frequency,
        cores: cores,
        threads: threads,
        gpu: gpu,
        tdp: tdp,
        family_code: family_code,
        socket: socket,
        scores: %{
          single: single_score,
          multi: multi_score
        }
      }
    end
  end

  defp parse_processors(html) do
    with {:ok, document} <- Floki.parse_document(html) do
      for node <- Floki.find(document, "#pc > tbody > tr > td.name") do
        link = Floki.find(node, "a")
        name = link |> Floki.text() |> String.trim()
        [path | _] = link |> Floki.attribute("href")

        %{
          name: name,
          links: %{"geekbench" => "https://browser.geekbench.com#{path}"}
        }
      end
    end
  end
end
