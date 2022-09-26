defmodule PczoneWeb.Schema.Orders do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :customer do
    field :name, non_null(:string)
    field :phone, non_null(:string)
  end

  object :order_item do
    field :order_id, non_null(:id)
    field :order, non_null(:order), resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :product_id, non_null(:id)
    field :product, non_null(:product), resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :from_built, :boolean
    field :price, non_null(:integer)
    field :quantity, non_null(:integer)
    field :amount, non_null(:integer)
  end

  object :order_built do
    field :order_id, non_null(:id)
    field :order, non_null(:order), resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :built_id, non_null(:id)
    field :built, non_null(:built), resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :price, non_null(:integer)
    field :quantity, non_null(:integer)
    field :amount, non_null(:integer)
  end

  object :order do
    field :code, non_null(:string)
    field :user_id, :id
    field :user, :user, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :customer_id, :id
    field :customer, :customer, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :shipping_address, :address
    field :tax_info, :tax_info
    field :state, :string
    field :total, :integer

    field :items, non_null(list_of(non_null(:order_item))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :builts, non_null(list_of(non_null(:order_built))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  object :order_list_result do
    field :entities, non_null(list_of(non_null(:order)))
    field :paging, non_null(:paging)
  end

  input_object :order_filter_input do
    field :code, :string_filter_input
  end

  input_object :order_item_filter_input do
    field :product_id, :id_filter_input
  end

  object :order_item_list_result do
    field :entities, non_null(list_of(non_null(:order_item)))
    field :paging, non_null(:paging)
  end

  object :order_queries do
    field :cart_items, non_null(:order_item_list_result) do
      arg :filter, :order_item_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn _args, %{context: context} ->
        {:ok, Pczone.Orders.get_cart_items(context)}
      end)
    end

    field :orders, non_null(:order_list_result) do
      arg :filter, :order_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Psus.list()

        {:ok, list}
      end)
    end
  end

  input_object :add_order_item_input do
    field :order_id, :id
    field :product_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :update_order_item_input do
    field :order_id, :id
    field :product_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :remove_order_item_input do
    field :order_id, :id
    field :product_id, non_null(:id)
  end

  input_object :add_order_built_input do
    field :order_id, :id
    field :built_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :update_order_built_input do
    field :order_id, :id
    field :built_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :remove_order_built_input do
    field :order_id, :id
    field :built_id, non_null(:id)
  end

  input_object :submit_order_input do
    field :item_ids, non_null(list_of(non_null(:id)))
    field :shipping_address, non_null(:address_input)
    field :tax_info, non_null(:tax_info_input)
  end

  object :order_mutations do
    field :create_order, non_null(:order) do
      resolve(fn _, _info ->
        Pczone.Orders.create()
      end)
    end

    field :add_order_item, non_null(:order_item) do
      arg :data, non_null(:add_order_item_input)

      resolve(fn %{data: data}, %{context: context} ->
        Pczone.Orders.add_item(data, context)
      end)
    end

    field :update_order_item, non_null(:order_item) do
      arg :data, non_null(:update_order_item_input)

      resolve(fn %{data: data}, %{context: context} ->
        Pczone.Orders.update_item(data, context)
      end)
    end

    field :remove_order_item, non_null(:order_item) do
      arg :data, non_null(:remove_order_item_input)

      resolve(fn %{data: data}, %{context: context} ->
        Pczone.Orders.remove_item(data, context)
      end)
    end

    field :add_order_built, non_null(:order_built) do
      arg :data, non_null(:add_order_built_input)

      resolve(fn %{data: data}, _info ->
        Pczone.Orders.add_built(data)
      end)
    end

    field :update_order_built, non_null(:order_built) do
      arg :data, non_null(:update_order_built_input)

      resolve(fn %{data: data}, _info ->
        Pczone.Orders.update_built(data)
      end)
    end

    field :remove_order_built, non_null(:order_built) do
      arg :data, non_null(:remove_order_built_input)

      resolve(fn %{data: data}, _info ->
        Pczone.Orders.remove_built(data)
      end)
    end

    field :submit_order, non_null(:order) do
      arg :data, non_null(:submit_order_input)

      resolve(fn %{data: data}, %{context: context} ->
        Pczone.Orders.submit(data, context)
      end)
    end
  end
end
