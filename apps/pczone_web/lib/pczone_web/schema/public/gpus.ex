defmodule PczoneWeb.Schema.Gpus do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :gpu do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :gpu_filter_input do
    field :code, :string_filter_input
    field :name, :string_filter_input
    field :type, :string_filter_input
  end

  object :gpu_list_result do
    field :entities, non_null(list_of(non_null(:gpu)))
    field :paging, non_null(:paging)
  end

  object :gpu_queries do
    field :gpus, non_null(:gpu_list_result) do
      arg :filter, :gpu_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Gpus.list()

        {:ok, list}
      end)
    end
  end
end
