defmodule XeonWeb.Schema.ProductCategories do
  use Absinthe.Schema.Notation
  alias Xeon.ProductCategories

  object :product_category do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :path, non_null(:string)
  end

  input_object :product_category_filter_input do
    field :id, :id_filter_input
    field :title, :string_filter_input
  end

  object :product_category_list_result do
    field :entities, non_null(list_of(non_null(:product)))
    field :paging, non_null(:paging)
  end

  object :product_category_queries do
    field :product_categories, non_null(:product_category_list_result) do
      arg :filter, :product_category_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: XeonWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> ProductCategories.list()

        {:ok, list}
      end)
    end
  end

  input_object :create_product_category_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :path, non_null(:string)
  end

  object :product_category_mutations do
    field :create_product_category, non_null(:product_category) do
      arg :data, non_null(:create_product_category_input)

      resolve(fn %{data: data}, _info ->
        ProductCategories.create(data)
      end)
    end
  end
end
