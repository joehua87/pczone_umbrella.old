defmodule Pczone.Processors do
  require Logger
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  import Pczone.Helpers
  alias Pczone.{Repo, Processor}

  def get_by_code(code) do
    Repo.one(from x in Processor, where: x.code == ^code, limit: 1)
  end

  def get(%Dew.Filter{filter: filter}) do
    Repo.one(from Processor, where: ^parse_filter(filter), limit: 1)
  end

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

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
    |> parse_chipset_filter(filter)
    |> select_fields(selection, [:attributes])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def get_map_by_code() do
    Repo.all(from c in Processor, select: {c.code, c.id}) |> Enum.into(%{})
  end

  def get_map_by_code(codes) when is_list(codes) do
    Repo.all(from p in Processor, where: p.code in ^codes, select: {p.code, p.id})
    |> Enum.into(%{})
  end

  def upsert(entities, opts \\ []) do
    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(entities, &parse_entity_for_upsert/1) do
      Repo.insert_all_2(
        Processor,
        list,
        Keyword.merge(opts,
          on_conflict:
            {:replace,
             [
               :slug,
               :name,
               :sub,
               :code_name,
               :collection_name,
               :launch_date,
               :status,
               :vertical_segment,
               :cache_size,
               :cores,
               :url,
               :memory_types,
               :socket,
               :case_temperature,
               :lithography,
               :base_frequency,
               :tdp_up_base_frequency,
               :tdp_down_base_frequency,
               :max_turbo_frequency,
               :tdp,
               :tdp_up,
               :tdp_down,
               :threads,
               :processor_graphics,
               :gpu_id,
               :ecc_memory_supported,
               :attributes
             ]},
          conflict_target: [:code]
        )
      )
    end
  end

  def parse_entity_for_upsert(params) do
    params
    |> Pczone.Helpers.ensure_slug()
    |> Pczone.Processor.new_changeset()
    |> Pczone.Helpers.get_changeset_changes()
  end

  def import_processors() do
    cursor = Mongo.find(:mongo, "Processor", %{"attributes.0" => %{"$exists" => true}})

    entities =
      [entity | _] =
      cursor
      |> Enum.map(&parse_processor/1)
      |> Enum.uniq_by(& &1.slug)

    Repo.insert_all_2(Processor, entities,
      on_conflict: {:replace, Map.keys(entity)},
      conflict_target: [:slug]
    )
  end

  def import_chipset_processors() do
    cursor =
      Mongo.find(:mongo, "IntelChipset", %{
        "attributes.0" => %{"$exists" => true},
        "processors.0" => %{"$exists" => true}
      })

    chipsets_map = Repo.all(from(c in Pczone.Chipset, select: {c.name, c.id})) |> Enum.into(%{})
    processors_map = Repo.all(from(p in Processor, select: {p.url, p.id})) |> Enum.into(%{})

    chipset_processors =
      Enum.flat_map(
        cursor,
        &parse_chipset_processor(&1,
          processors_map: processors_map,
          chipsets_map: chipsets_map
        )
      )

    Repo.insert_all_2("chipset_processor", chipset_processors)
  end

  defp parse_chipset_processor(%{"title" => chipset_name, "processors" => processors},
         processors_map: processors_map,
         chipsets_map: chipsets_map
       ) do
    processors
    |> Enum.reduce([], fn %{"url" => url}, acc ->
      processor_url =
        String.replace("https://ark.intel.com#{url}", "products/sku", "ark/products")

      case processors_map[processor_url] do
        nil ->
          acc

        processor_id ->
          acc ++ [%{processor_id: processor_id, chipset_id: chipsets_map[chipset_name]}]
      end
    end)
  end

  defp parse_processor(%{
         "title" => name,
         "subtitle" => sub,
         "url" => url,
         "attributes" => attributes
       }) do
    extract_attributes(attributes, [
      %{key: :code, group: "Essentials", label: "Processor Number"},
      %{key: :code_name, group: "Essentials", label: "Code Name"},
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

  def parse_chipset_filter(acc, %{chipset_id: %{eq: chipset_id}}) do
    chipset_processor_query =
      from pc in Pczone.ChipsetProcessor,
        where: pc.chipset_id == ^chipset_id,
        select: pc.processor_id

    from p in acc, where: p.id in subquery(chipset_processor_query)
  end

  def parse_chipset_filter(acc, _) do
    acc
  end
end
