defmodule Xeon.Motherboards do
  import Dew.FilterParser
  import Ecto.Query, only: [from: 2, where: 2]
  alias Xeon.{Repo, Motherboard, MotherboardProcessor}

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
    chipsets_map = Xeon.Chipsets.get_map_by_shortname()
    entities = Enum.map(entities, &parse_entity_for_upsert(&1, chipsets_map: chipsets_map))

    Repo.insert_all(
      Motherboard,
      entities,
      Keyword.merge(opts, on_conflict: :replace_all, conflict_target: [:slug])
    )
  end

  def parse_entity_for_upsert(params, chipsets_map: chipsets_map) do
    case params do
      %{chipset: chipset_shortname} ->
        Map.put(params, :chipset_id, chipsets_map[chipset_shortname])

      %{"chipset" => chipset_shortname} ->
        Map.put(params, "chipset_id", chipsets_map[chipset_shortname])
    end
    |> Xeon.Helpers.ensure_slug()
    |> Xeon.Motherboard.new_changeset()
    |> Xeon.Helpers.get_changeset_changes()
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
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")

    cursor =
      Mongo.find(conn, "Product", %{
        "fieldValues.0" => %{"$exists" => true}
      })

    chipsets_map = Xeon.Chipsets.get_map_by_shortname()

    motherboards =
      Enum.map(cursor, &parse(&1, chipsets_map: chipsets_map))
      |> Enum.filter(&(&1.chipset_id != nil))
      |> Enum.map(&Map.delete(&1, :chipset))

    Repo.insert_all(Xeon.Motherboard, motherboards)
  end

  defp parse(%{"title" => name, "fieldValues" => field_values}, chipsets_map: chipsets_map) do
    chipset = get_field_value(field_values, "Chipset")
    chipset_id = chipsets_map[chipset]
    memory_slots = get_field_value(field_values, "RAM slots") |> String.to_integer()

    max_memory_capacity =
      get_field_value(field_values, "RAM max") |> String.replace(" GB", "") |> String.to_integer()

    {type, supported_types} =
      Xeon.MemoryTypes.get(:hardware_corner, get_field_value(field_values, "RAM"))

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      processor_slots: [
        %Xeon.ProcessorSlot{
          quantity: 1
        }
      ],
      memory_slots: [
        %Xeon.MemorySlot{
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
