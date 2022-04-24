defmodule Xeon.Motherboards do
  alias Ecto.Multi

  alias Xeon.{
    Repo,
    MemoryType,
    ProcessorCollection,
    Motherboard,
    MotherboardMemoryType,
    MotherboardProcessorCollection,
    Helpers.GoogleSheets
  }

  def import() do
    rows = GoogleSheets.get_connection() |> GoogleSheets.read_doc("motherboard!A:Z")

    items =
      for %{
            "chipset" => "" <> chipset,
            "compatible" => _compatible,
            "form" => _form,
            "max_memory_capacity" => max_memory_capacity,
            "memory_slot" => memory_slot,
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
          memory_slot: to_integer(memory_slot),
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
end
