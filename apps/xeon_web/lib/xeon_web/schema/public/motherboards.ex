defmodule XeonWeb.Schema.Motherboards do
  use Absinthe.Schema.Notation

  alias Xeon.Motherboards

  object :chipset do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :processors, non_null(list_of(non_null(:processor)))
  end

  object :memory do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end

  object :drive do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end

  object :motherboard do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :max_memory_capacity, non_null(:string)
    field :memory_types, non_null(list_of(non_null(:string)))
    field :memory_slots, non_null(:integer)
    field :processor_slots, non_null(:integer)
    field :chipset, non_null(:chipset)
  end

  input_object :motherboard_filter_input do
    field :id, :id_filter_input
    field :name, :string_filter_input
  end

  object :motherboard_list_result do
    field :entities, non_null(list_of(non_null(:motherboard)))
    field :paging, non_null(:paging)
  end

  object :built_specs_result do
    field :processors, non_null(list_of(non_null(:processor)))
    field :memories, non_null(list_of(non_null(:memory)))
    field :drives, non_null(list_of(non_null(:drive)))
  end

  object :motherboard_queries do
    field :built_specs, non_null(:built_specs_result) do
      arg :motherboard_id, non_null(:id)

      resolve fn %{motherboard_id: motherboard_id}, info ->
        Motherboards.get_built_specs(motherboard_id)
      end
    end

    field :motherboards, non_null(:motherboard_list_result) do
      arg :filter, :motherboard_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: XeonWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Motherboards.list()

        {:ok, list}
      end
    end

    field :motherboard, :motherboard do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Motherboards.get(id)}
      end)
    end

    field :motherboard_by, :motherboard do
      arg :filter, :motherboard_filter_input

      resolve(fn args, _info ->
        {:ok, Motherboards.get(args)}
      end)
    end
  end
end
