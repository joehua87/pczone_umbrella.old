defmodule PczoneWeb.Schema.Taxonomies do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :taxon do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :path, non_null(:string)
    field :description, :string
  end

  object :taxonomy do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)

    field :taxons, non_null(list_of(non_null(:taxon))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :taxonomy_filter_input do
    field :code, :string_filter_input
    field :name, :string_filter_input
  end

  object :taxonomy_list_result do
    field :entities, non_null(list_of(non_null(:taxonomy)))
    field :paging, non_null(:paging)
  end

  object :taxonomy_queries do
    field :taxonomies, non_null(:taxonomy_list_result) do
      arg :filter, :taxonomy_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Taxonomies.list()

        {:ok, list}
      end)
    end
  end
end
