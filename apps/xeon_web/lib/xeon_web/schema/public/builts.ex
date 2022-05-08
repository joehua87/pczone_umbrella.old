defmodule XeonWeb.Schema.Builts do
  use Absinthe.Schema.Notation
  alias Xeon.Builts

  object :built_queries do
    field :built_processors, non_null(list_of(non_null(:processor))) do
      arg :motherboard_id, non_null(:id)

      resolve fn %{motherboard_id: motherboard_id}, _info ->
        with entities when is_list(entities) <- Builts.get_processors(motherboard_id) do
          {:ok, entities}
        end
      end
    end

    field :built_memories, non_null(list_of(non_null(:memory))) do
      arg :motherboard_id, non_null(:id)

      resolve fn %{motherboard_id: motherboard_id}, _info ->
        with entities when is_list(entities) <- Builts.get_memories(motherboard_id) do
          {:ok, entities}
        end
      end
    end
  end
end
