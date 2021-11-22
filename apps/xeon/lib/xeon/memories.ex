defmodule Xeon.Memories do
  alias Ecto.Multi

  alias Xeon.{
    Repo,
    Memory,
    MemoryType,
    Helpers.GoogleSheets
  }

  def import() do
    items = GoogleSheets.get_connection() |> GoogleSheets.read_doc("memory!A:Z")

    memory_types =
      items
      |> Enum.map(& &1["memory_type"])
      |> Enum.uniq()
      |> Enum.map(&%{name: &1})

    Multi.new()
    |> Multi.insert_all(:memory_types, MemoryType, memory_types,
      on_conflict: :replace_all,
      conflict_target: :name,
      returning: true
    )
    |> Multi.run(
      :memories,
      fn _,
         %{
           memory_types: {_, memory_types}
         } ->
        memory_types_map = memory_types |> Enum.map(&{&1.name, &1.id}) |> Enum.into(%{})

        memories =
          Enum.map(
            items,
            fn %{"name" => name, "capacity" => capacity, "memory_type" => memory_type} ->
              %{
                name: name,
                capacity: to_integer(capacity),
                memory_type_id: memory_types_map[memory_type]
              }
            end
          )

        with {_, _} = result <-
               Repo.insert_all(Memory, memories, on_conflict: :nothing) do
          {:ok, result}
        end
      end
    )
    |> Repo.transaction()
  end

  def to_integer(nil), do: nil

  def to_integer(v), do: String.to_integer(v)
end
