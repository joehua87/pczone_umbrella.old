defmodule PcZone.Motherboards do
  import Dew.FilterParser
  import Ecto.Query, only: [from: 2, where: 2]
  alias PcZone.{Repo, Motherboard, MotherboardProcessor}

  def get_by_code(code) do
    Repo.one(from x in Motherboard, where: x.code == ^code, limit: 1)
  end

  def get_map_by_slug() do
    Repo.all(from m in Motherboard, select: {m.slug, m.id}) |> Enum.into(%{})
  end

  def get_map_by_slug(slugs) when is_list(slugs) do
    Repo.all(from m in Motherboard, where: m.slug in ^slugs, select: {m.slug, m.id})
    |> Enum.into(%{})
  end

  def get(id) do
    Repo.get(Motherboard, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Motherboard
    |> where(^parse_filter(filter))
    |> select_fields(selection, [:attributes])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(entities, opts \\ []) do
    brands_map = PcZone.Brands.get_map_by_slug()
    chipsets_map = PcZone.Chipsets.get_map_by_code()

    entities =
      Enum.map(
        entities,
        &parse_entity_for_upsert(&1, brands_map: brands_map, chipsets_map: chipsets_map)
      )

    Repo.insert_all_2(
      Motherboard,
      entities,
      Keyword.merge(opts,
        on_conflict:
          {:replace,
           [
             :slug,
             :code,
             :name,
             :max_memory_capacity,
             :chipset_id,
             :brand_id,
             :note,
             :chassis_form_factors,
             :memory_slots_count,
             :processor_slots_count,
             :sata_slots_count,
             :m2_slots_count,
             :pci_slots_count,
             :memory_slots,
             :processor_slots,
             :sata_slots,
             :m2_slots,
             :pci_slots,
             :attributes
           ]},
        conflict_target: [:slug]
      )
    )
  end

  def upsert_motherboard_processors(entities, opts \\ []) do
    motherboard_slugs =
      entities
      |> Enum.map(&PcZone.Helpers.ensure_slug/1)
      |> Enum.map(fn
        %{"slug" => slug} -> slug
        %{slug: slug} -> slug
        _ -> nil
      end)
      |> Enum.filter(&(&1 != nil))

    processor_codes =
      Enum.flat_map(entities, fn
        %{"processors" => processor_codes = [_ | _]} -> processor_codes
        %{processors: processor_codes = [_ | _]} -> processor_codes
        _ -> []
      end)
      |> Enum.filter(&(&1 != nil))

    motherboards_map = get_map_by_slug(motherboard_slugs)
    processors_map = PcZone.Processors.get_map_by_code(processor_codes)

    entities =
      entities
      |> Enum.map(&PcZone.Helpers.ensure_slug/1)
      |> Enum.flat_map(fn
        %{slug: slug, processors: processors = [_ | _]} ->
          Enum.map(
            processors,
            &%{
              motherboard_id: motherboards_map[slug],
              processor_id: processors_map[&1]
            }
          )

        %{"slug" => slug, "processors" => processors = [_ | _]} ->
          Enum.map(
            processors,
            &%{
              motherboard_id: motherboards_map[slug],
              processor_id: processors_map[&1]
            }
          )

        _ ->
          []
      end)
      |> Enum.filter(&(&1.motherboard_id != nil && &1.processor_id != nil))

    Repo.insert_all_2(PcZone.MotherboardProcessor, entities, opts)
  end

  def parse_entity_for_upsert(params, brands_map: brands_map, chipsets_map: chipsets_map) do
    case params do
      %{chipset: chipset_code} ->
        Map.put(params, :chipset_id, chipsets_map[chipset_code])

      %{"chipset" => chipset_code} ->
        Map.put(params, "chipset_id", chipsets_map[chipset_code])
    end
    |> case do
      params = %{brand: brand} -> Map.put(params, :brand_id, brands_map[brand])
      params = %{"brand" => brand} -> Map.put(params, "brand_id", brands_map[brand])
    end
    |> PcZone.Helpers.ensure_slug()
    |> PcZone.Motherboard.new_changeset()
    |> PcZone.Helpers.get_changeset_changes()
  end

  def add_processor(params) do
    params
    |> MotherboardProcessor.new_changeset()
    |> Repo.insert()
  end

  def remove_processor(%{motherboard_id: motherboard_id, processor_id: processor_id}) do
    Repo.delete_all(
      from(MotherboardProcessor,
        where: [motherboard_id: ^motherboard_id, processor_id: ^processor_id]
      )
    )
  end

  def update_processors(%{motherboard_id: motherboard_id, processor_ids: processor_ids}) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete,
      from(mp in MotherboardProcessor,
        where: mp.motherboard_id == ^motherboard_id and mp.processor_id in ^processor_ids
      )
    )
    |> Ecto.Multi.insert_all(
      :insert,
      MotherboardProcessor,
      Enum.map(processor_ids, &%{motherboard_id: motherboard_id, processor_id: &1})
    )
    |> Repo.transaction()
  end

  def import_barebone_motherboards() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/pc_zone")

    cursor =
      Mongo.find(conn, "Product", %{
        "fieldValues.0" => %{"$exists" => true}
      })

    chipsets_map = PcZone.Chipsets.get_map_by_code()

    motherboards =
      Enum.map(cursor, &parse(&1, chipsets_map: chipsets_map))
      |> Enum.filter(&(&1.chipset_id != nil))
      |> Enum.map(&Map.delete(&1, :chipset))

    Repo.insert_all_2(PcZone.Motherboard, motherboards)
  end

  defp parse(%{"title" => name, "fieldValues" => field_values}, chipsets_map: chipsets_map) do
    chipset = get_field_value(field_values, "Chipset")
    chipset_id = chipsets_map[chipset]
    memory_slots = get_field_value(field_values, "RAM slots") |> String.to_integer()

    max_memory_capacity =
      get_field_value(field_values, "RAM max") |> String.replace(" GB", "") |> String.to_integer()

    {type, supported_types} =
      PcZone.MemoryTypes.get(:hardware_corner, get_field_value(field_values, "RAM"))

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      processor_slots: [
        %PcZone.ProcessorSlot{
          quantity: 1
        }
      ],
      memory_slots: [
        %PcZone.MemorySlot{
          type: type,
          supported_types: supported_types,
          quantity: memory_slots
        }
      ],
      processor_slots_count: 1,
      memory_slots_count: memory_slots,
      max_memory_capacity: max_memory_capacity,
      sata_slots: [],
      m2_slots: [],
      pci_slots: [],
      attributes: []
    }
  end

  defp get_field_value(field_values, label) do
    case Enum.find(field_values, &(&1["label"] == label)) do
      nil -> nil
      %{"value" => value} -> value
    end
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
