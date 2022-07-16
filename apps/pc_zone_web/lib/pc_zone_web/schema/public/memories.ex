defmodule PcZoneWeb.Schema.Memories do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :memory do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :type, non_null(:string)
    field :capacity, non_null(:integer)
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  input_object :memory_filter_input do
    field :name, :string_filter_input
    field :type, :string_filter_input
  end

  object :memory_list_result do
    field :entities, non_null(list_of(non_null(:memory)))
    field :paging, non_null(:paging)
  end

  object :memory_queries do
    field :memories, non_null(:memory_list_result) do
      arg :filter, :memory_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> PcZone.Memories.list()

        {:ok, list}
      end)
    end
  end

  object :memory_mutations do
    field :upsert_memories, non_null(list_of(non_null(:memory))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- PcZone.Memories.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
