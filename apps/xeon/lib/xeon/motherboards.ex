defmodule Xeon.Motherboards do
  alias Ecto.Multi
  import Dew.FilterParser
  import Ecto.Query, only: [from: 2, where: 2]

  alias Xeon.{
    Repo,
    MemoryType,
    ProcessorCollection,
    Motherboard,
    MotherboardMemoryType,
    MotherboardProcessorCollection,
    Helpers.GoogleSheets
  }

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

  def get_built_specs(motherboard_id) do
    %{chipset_id: chipset_id} = get(motherboard_id)

    processor_ids_query =
      from pc in Xeon.ProcessorChipset,
        where: pc.chipset_id == ^chipset_id,
        select: pc.processor_id

    processors = Repo.all(from p in Xeon.Processor, where: p.id in subquery(processor_ids_query))
    {:ok, %{processors: processors, memories: [], drives: []}}
  end

  def import_barebone_motherboards() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")

    cursor =
      Mongo.find(conn, "Product", %{
        "fieldValues.0" => %{"$exists" => true}
      })

    chipsets_map = Repo.all(from c in Xeon.Chipset, select: {c.shortname, c.id}) |> Enum.into(%{})

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

    memory_types =
      %{
        "DIMM DDR3-1333" => ["DIMM DDR3-1333"],
        "DIMM DDR3-1333/1600" => ["DIMM DDR3-1333", "DIMM DDR3-1600"],
        "DIMM DDR3-1600" => ["DIMM DDR3-1600"],
        "SODIMM DDR3-1600" => ["SODIMM DDR3-1600"],
        "DIMM DDR3L-1600" => ["DIMM DDR3L-1600"],
        "SODIMM DDR3L-1600" => ["SODIMM DDR3L-1600"],
        "DIMM DDR4-2133/2400" => ["DIMM DDR4-2133", "DIMM DDR4-2400"],
        "SODIMM DDR4-2133/2400" => ["SODIMM DDR4-2133", "SODIMM DDR4-2400"],
        "DIMM DDR4-2400/2666" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
        "SODIMM DDR4-2400/2666" => ["SODIMM DDR4-2400", "SODIMM DDR4-2666"],
        "DIMM DDR4-2666" => ["DIMM DDR4-2666"],
        "SODIMM DDR4-2666" => ["SODIMM DDR4-2666"],
        "DIMM DDR4-2666/2933" => ["DIMM DDR4-2666", "DIMM DDR4-2933"],
        "SODIMM DDR4-2666/2933" => ["SODIMM DDR4-2666", "SODIMM DDR4-2933"],
        "DIMM DDR4-2666/2933/3200" => ["DIMM DDR4-2666", "DIMM DDR4-2933", "DIMM DDR4-3200"],
        "DIMM DDR4-2133" => ["DIMM DDR4-2133"],
        "SODIMM DDR4-2133" => ["SODIMM DDR4-2133"],
        "SODIMM-2133/2400" => ["SODIMM-2133", "SODIMM-2400"],
        "DIMM DDR3-1060/1333" => ["DIMM DDR3-1060", "DIMM DDR3-1333"],
        "DIMM DDR3-1333/1866" => ["DIMM DDR3-1333", "DIMM DDR3-1866"],
        "DIMM DDR4-2400/2667" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
        "DIMM DDR4-2666/3000" => ["DIMM DDR4-2666", "DIMM DDR4-3000"],
        "DIMM DDR4-2933/3400" => ["DIMM DDR4-2933", "DIMM DDR4-3400"],
        "DIMM DDR4-3200/3400" => ["DIMM DDR4-3200", "DIMM DDR4-3400"],
        "DIMM DDR4-4400" => ["DIMM DDR4-4400"],
        "DIMM DDR3-2133" => ["DIMM DDR3-2133"],
        "DIMM DDR4-2133/2667" => ["DIMM DDR4-2133", "DIMM DDR4-2667"],
        "DIMM DDR4-2666/3200" => ["DIMM DDR4-2666", "DIMM DDR4-3200"],
        "SO-DIMM DDR3-1333" => ["SODIMM DDR3-1333"],
        "DIMM DDR4-2400" => ["DIMM DDR4-2400"],
        "DIMM DDR3-2133/2400" => ["DIMM DDR3-2133", "DIMM DDR3-2400"],
        "SODIMM DDR4-2400" => ["SODIMM DDR4-2400"],
        "SODIMM DDR4-2933" => ["SODIMM DDR4-2933"],
        "DIMM DDR4-2933" => ["DIMM DDR4-2933"],
        "SODIMM DDR4-3200" => ["SODIMM DDR4-3200"],
        "DIMM DDR4-3200" => ["DIMM DDR4-3200"],
        "SDIMM DDR3-1600" => ["SODIMM DDR3-1600"]
      }[get_field_value(field_values, "RAM")]

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      memory_types: memory_types,
      memory_slots: memory_slots,
      processor_slots: 1,
      max_memory_capacity: max_memory_capacity
    }
  end

  defp get_field_value(field_values, label) do
    case Enum.find(field_values, &(&1["label"] == label)) do
      nil -> nil
      %{"value" => value} -> value
    end
  end

  def import() do
    rows = GoogleSheets.get_connection() |> GoogleSheets.read_doc("motherboard!A:Z")

    items =
      for %{
            "chipset" => "" <> chipset,
            "compatible" => _compatible,
            "form" => _form,
            "max_memory_capacity" => max_memory_capacity,
            "memory_slots" => memory_slots,
            "memory_types" => memory_types,
            "name" => name,
            "note" => note,
            "price" => _price,
            "processor_families" => processor_families,
            "processor_slot" => processor_slot,
            "separate_cpu_power_pin" => _separate_cpu_power_pin,
            "socket" => socket,
            "state" => _state,
            "url" => _url
          } <- rows do
        %{
          name: name,
          chipset: chipset,
          max_memory_capacity: to_integer(max_memory_capacity),
          memory_slots: to_integer(memory_slots),
          processor_slot: to_integer(processor_slot),
          note: note,
          memory_types: split_array(memory_types),
          processor_families: split_array(processor_families),
          socket: socket
          # compatible: compatible
        }
      end

    memory_types =
      items
      |> Enum.flat_map(& &1.memory_types)
      |> Enum.uniq()
      |> Enum.map(&%{name: &1})

    processor_families =
      items
      |> Enum.flat_map(& &1.processor_families)
      |> Enum.uniq()
      |> Enum.map(&%{name: &1})

    motherboards = Enum.map(items, &Map.drop(&1, [:memory_types, :processor_families]))

    Multi.new()
    |> Multi.insert_all(:memory_types, MemoryType, memory_types,
      on_conflict: :replace_all,
      conflict_target: :name,
      returning: true
    )
    |> Multi.insert_all(:processor_families, ProcessorCollection, processor_families,
      on_conflict: :replace_all,
      conflict_target: :name,
      returning: true
    )
    |> Multi.insert_all(:motherboards, Motherboard, motherboards,
      on_conflict: :replace_all,
      conflict_target: :name,
      returning: true
    )
    |> Multi.run(
      :motherboard_memory_types,
      fn _,
         %{
           memory_types: {_, memory_types},
           motherboards: {_, motherboards}
         } ->
        motherboards_map = motherboards |> Enum.map(&{&1.name, &1.id}) |> Enum.into(%{})
        memory_types_map = memory_types |> Enum.map(&{&1.name, &1.id}) |> Enum.into(%{})

        motherboard_memory_types =
          Enum.flat_map(items, fn %{name: motherboard_name, memory_types: memory_types} ->
            Enum.map(
              memory_types,
              &%{
                motherboard_id: motherboards_map[motherboard_name],
                memory_type_id: memory_types_map[&1]
              }
            )
          end)

        with {_, _} = result <-
               Repo.insert_all(MotherboardMemoryType, motherboard_memory_types,
                 on_conflict: :nothing
               ) do
          {:ok, result}
        end
      end
    )
    |> Multi.run(
      :motherboard_processor_families,
      fn _,
         %{
           processor_families: {_, processor_families},
           motherboards: {_, motherboards}
         } ->
        motherboards_map = motherboards |> Enum.map(&{&1.name, &1.id}) |> Enum.into(%{})

        processor_families_map =
          processor_families |> Enum.map(&{&1.name, &1.id}) |> Enum.into(%{})

        motherboard_processor_families =
          Enum.flat_map(items, fn %{
                                    name: motherboard_name,
                                    processor_families: processor_families
                                  } ->
            Enum.map(
              processor_families,
              &%{
                motherboard_id: motherboards_map[motherboard_name],
                processor_collection_id: processor_families_map[&1]
              }
            )
          end)

        with {_, _} = result <-
               Repo.insert_all(MotherboardProcessorCollection, motherboard_processor_families,
                 on_conflict: :nothing
               ) do
          {:ok, result}
        end
      end
    )
    |> Repo.transaction()
  end

  def to_integer(nil), do: nil

  def to_integer(v), do: String.to_integer(v)

  defp split_array(nil), do: []

  defp split_array(content) do
    content
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
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
