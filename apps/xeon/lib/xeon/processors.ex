defmodule Xeon.Processors do
  alias Xeon.{Repo, Processor, ProcessorScore}
  @url "https://browser.geekbench.com/processor-benchmarks"
  @cache_dir "/Users/achilles/.cache"

  def create(params) do
    Processor.new(params) |> Repo.insert()
  end

  def import_processors() do
    processors = get_processors()
    Repo.insert_all(Processor, processors, returning: true, on_conflict: :nothing)
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
      })
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
      with {:ok, %{body: html}} <-
             Finch.build(:get, url) |> Finch.request(MyFinch),
           :ok <- cache_path |> Path.dirname() |> File.mkdir_p(),
           :ok <- File.write(cache_path, html) do
        {:ok, html}
      end
    end
  end

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
