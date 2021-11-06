defmodule Xeon.Motherboards do
  alias Ecto.Multi

  alias Xeon.{
    Repo,
    MemoryType,
    ProcessorFamily,
    Motherboard,
    MotherboardMemoryType,
    MotherboardProcessorFamily
  }

  @headers [
    "name",
    "state",
    "chipset",
    "max_memory_capacity",
    "memory_slot",
    "processor_slot",
    "note",
    "memory_types",
    "processor_families",
    "socket",
    "compatible",
    "url"
  ]
  def import() do
    headers = @headers

    [^headers | rows] =
      :code.priv_dir(:xeon)
      |> Path.join("data/motherboards.csv")
      |> File.read!()
      |> TabCsvParser.parse_string(skip_headers: false)

    items =
      for [
            name,
            "published",
            chipset,
            max_memory_capacity,
            memory_slot,
            processor_slot,
            note,
            memory_types,
            processor_families,
            socket,
            _compatible,
            _url
          ] <- rows do
        %{
          name: name,
          chipset: chipset,
          max_memory_capacity: String.to_integer(max_memory_capacity),
          memory_slot: String.to_integer(memory_slot),
          processor_slot: String.to_integer(processor_slot),
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
    |> Multi.insert_all(:processor_families, ProcessorFamily, processor_families,
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
                processor_family_id: processor_families_map[&1]
              }
            )
          end)

        with {_, _} = result <-
               Repo.insert_all(MotherboardProcessorFamily, motherboard_processor_families,
                 on_conflict: :nothing
               ) do
          {:ok, result}
        end
      end
    )
    |> Repo.transaction()
  end

  defp split_array(content) do
    content
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
  end
end
