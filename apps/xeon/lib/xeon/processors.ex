defmodule Xeon.Processors do
  require Logger
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  import Xeon.Helpers
  alias Xeon.{Repo, Processor}

  def get(id) do
    Repo.get(Processor, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Processor
    |> where(^parse_filter(filter))
    |> select_fields(selection, [:attributes])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def import_processors() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")
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
    extract_attributes(attributes, [
      %{key: :code, group: "Essentials", label: "Processor Number"},
      %{key: :collection_name, group: "Essentials", label: "Product Collection"},
      %{
        key: :launch_date,
        group: "Essentials",
        label: "Launch Date",
        transform: &parse_launch_date/1
      },
      %{key: :status, group: "Essentials", label: "Status"},
      %{key: :vertical_segment, group: "Essentials", label: "Vertical Segment"},
      %{key: :collection_name, group: "Essentials", label: "Product Collection"},
      %{key: :lithography, group: "Essentials", label: "Lithography"},
      %{key: :socket, group: "Package Specifications", label: "Sockets Supported"},
      %{
        key: :cache_size,
        group: "CPU Specifications",
        label: "Cache",
        transform: &parse_cache_size/1
      },
      %{
        key: :memory_types,
        group: "Memory Specifications",
        label: "Memory Types",
        transform: &parse_memory_types/1
      },
      %{
        key: :case_temperature,
        group: "Package Specifications",
        label: "TCASE",
        transform: &parse_temperuture/1
      },
      %{
        key: :cores,
        group: "CPU Specifications",
        label: "Total Cores",
        transform: &parse_integer/1
      },
      %{
        key: :threads,
        group: "CPU Specifications",
        label: "Total Threads",
        transform: &parse_integer/1
      },
      %{
        key: :tdp,
        group: "CPU Specifications",
        label: "TDP",
        transform: &parse_decimal(&1, " W")
      },
      %{
        key: :tdp_up,
        group: "CPU Specifications",
        label: "Configurable TDP-up",
        transform: &parse_decimal(&1, " W")
      },
      %{
        key: :tdp_down,
        group: "CPU Specifications",
        label: "Configurable TDP-down",
        transform: &parse_decimal(&1, " W")
      },
      %{
        key: :base_frequency,
        group: "CPU Specifications",
        label: "Processor Base Frequency",
        transform: &parse_frequency/1
      },
      %{
        key: :tdp_up_base_frequency,
        group: "CPU Specifications",
        label: "Configurable TDP-up Base Frequency",
        transform: &parse_frequency/1
      },
      %{
        key: :tdp_down_base_frequency,
        group: "CPU Specifications",
        label: "Configurable TDP-down Base Frequency",
        transform: &parse_frequency/1
      },
      %{
        key: :max_turbo_frequency,
        group: "CPU Specifications",
        label: "Max Turbo Frequency",
        transform: &parse_frequency/1
      }
    ])
    |> Map.merge(%{
      name: name,
      sub: sub,
      url: url,
      attributes: parse_attributes(attributes)
    })
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

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :code -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
