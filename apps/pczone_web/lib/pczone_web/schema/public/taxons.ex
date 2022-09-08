defmodule PczoneWeb.Schema.Taxons do
  use Absinthe.Schema.Notation

  object :taxon do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :path, non_null(:string)
    field :description, :string
  end

  input_object :taxon_filter_input do
    field :name, :string_filter_input
    field :path, :path_filter_input
    field :taxonomy_id, :id_filter_input
    field :taxonomy, :taxonomy_filter_input
    field :products, :product_filter_input
    field :built_templates, :built_template_filter_input
  end

  object :taxon_list_result do
    field :entities, non_null(list_of(non_null(:taxon)))
    field :paging, non_null(:paging)
  end

  object :taxon_queries do
    field :taxons, non_null(:taxon_list_result) do
      arg :filter, :taxon_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Taxons.list()

        {:ok, list}
      end)
    end
  end
end
