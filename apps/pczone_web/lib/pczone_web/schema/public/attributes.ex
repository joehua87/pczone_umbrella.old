defmodule PczoneWeb.Schema.Attributes do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :attribute_item do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :path, non_null(:string)
    field :description, :string
  end

  object :attribute do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)

    field :items, non_null(list_of(non_null(:attribute_item))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :attribute_filter_input do
    field :code, :string_filter_input
    field :name, :string_filter_input
  end

  object :attribute_list_result do
    field :entities, non_null(list_of(non_null(:attribute)))
    field :paging, non_null(:paging)
  end

  object :attribute_queries do
    field :attributes, non_null(:attribute_list_result) do
      arg :filter, :attribute_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Attributes.list()

        {:ok, list}
      end)
    end
  end
end
