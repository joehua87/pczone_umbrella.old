defmodule PczoneWeb.Schema.StoreProducts do
  use Absinthe.Schema.Notation

  object :product_option do
    field :name, non_null(:string)
    field :values, non_null(list_of(non_null(:string)))
  end

  object :store_product do
    field :id, non_null(:id)
    field :store_id, non_null(:id)
    field :store, non_null(:store)
    field :product_code, non_null(:string)
    field :name, non_null(:string)
    field :description, :string
    field :product_id, :id
    field :product, :product
    field :built_template_id, :id
    field :built_template, :built_template
    field :options, non_null(list_of(non_null(:product_option)))
    field :images, non_null(list_of(non_null(:embedded_medium)))
    field :sold, :integer
    field :stats, :json
    field :created_at, non_null(:datetime)
  end

  input_object :store_product_filter_input do
    field :store_id, :id_filter_input
  end

  object :store_product_list_result do
    field :entities, non_null(list_of(non_null(:store_product)))
    field :paging, non_null(:paging)
  end

  object :store_product_queries do
    field :store_products, non_null(:store_product_list_result) do
      arg :filter, :store_product_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.StoreProducts.list()

        {:ok, list}
      end)
    end
  end
end
