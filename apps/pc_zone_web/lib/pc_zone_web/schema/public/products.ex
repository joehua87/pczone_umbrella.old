defmodule PcZoneWeb.Schema.Products do
  use Absinthe.Schema.Notation
  alias PcZone.Products

  object :product do
    field :id, non_null(:id)
    field :sku, non_null(:string)
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :condition, non_null(:string)
    field :type, :product_type
    field :list_price, :integer
    field :sale_price, non_null(:integer)
    field :percentage_off, non_null(:decimal)
    field :stock, non_null(:integer)
    field :category_id, :id
    field :category, :product_category
    field :barebone_id, :id
    field :motherboard_id, :id
    field :processor_id, :id
    field :memory_id, :id
    field :gpu_id, :id
    field :hard_drive_id, :id
    field :psu_id, :id
    field :chassis_id, :id
  end

  input_object :product_filter_input do
    field :id, :id_filter_input
    field :title, :string_filter_input
    field :condition, :string_filter_input
  end

  object :product_list_result do
    field :entities, non_null(list_of(non_null(:product)))
    field :paging, non_null(:paging)
  end

  object :product_queries do
    field :products, non_null(:product_list_result) do
      arg :filter, :product_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Products.list()

        {:ok, list}
      end)
    end

    field :product, :product do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Products.get(id)}
      end)
    end

    field :product_by, :product do
      arg :filter, :product_filter_input

      resolve(fn args, _info ->
        {:ok, Products.get(args)}
      end)
    end
  end

  input_object :create_product_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :condition, non_null(:string)
    field :list_price, :integer
    field :sale_price, non_null(:integer)
    field :stock, :integer
    field :type, non_null(:product_type)
    field :category_id, :id
    field :barebone_id, :id
    field :motherboard_id, :id
    field :processor_id, :id
    field :memory_id, :id
    field :gpu_id, :id
    field :hard_drive_id, :id
    field :psu_id, :id
    field :chassis_id, :id
  end

  input_object :update_product_input do
    field :id, non_null(:string)
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :integer
    field :sale_price, :integer
    field :stock, :integer
    field :category_id, :id
  end

  object :product_mutations do
    field :create_product, non_null(:product) do
      arg :data, non_null(:create_product_input)

      resolve(fn %{data: data}, _info ->
        Products.create(data)
      end)
    end

    field :update_product, non_null(:product) do
      arg :data, non_null(:update_product_input)

      resolve(fn %{data: data}, _info ->
        Products.update(data)
      end)
    end
  end
end
