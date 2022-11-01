defmodule Pczone.Orders.Transition do
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Repo, Products, Orders}

  def transit(action, order_id, params, context) when is_bitstring(order_id) do
    order = Repo.get(Pczone.Order, order_id)
    transit(action, order, params, context)
  end

  def transit(
        :submit,
        %Pczone.Order{id: order_id, state: :cart},
        %{item_ids: item_ids} = params,
        context
      ) do
    shipping_address = get_shipping_address(params)
    tax_info = get_tax_info(params)

    items =
      Repo.all(from(i in Pczone.OrderItem, where: i.order_id == ^order_id and i.id in ^item_ids))

    case items do
      [] ->
        {:error, "Item ids must be more than 1"}

      _ ->
        products_price_map = items |> Enum.map(& &1.product_id) |> Products.get_price_map()

        items =
          Enum.map(items, fn %{product_id: product_id, quantity: quantity} ->
            price = products_price_map[product_id]
            now = DateTime.utc_now() |> DateTime.truncate(:second)

            %{
              product_id: product_id,
              price: price,
              quantity: quantity,
              amount: price * quantity,
              inserted_at: now,
              updated_at: now
            }
          end)

        Ecto.Multi.new()
        |> Ecto.Multi.run(:order, fn _, _ ->
          total = items |> Enum.map(& &1.amount) |> Enum.sum()

          Orders.create(
            %{
              state: :submitted,
              shipping_address: shipping_address,
              tax_info: tax_info,
              total: total
            },
            context
          )
        end)
        |> Ecto.Multi.run(:items, fn _, %{order: new_order} ->
          items = Enum.map(items, &Map.put(&1, :order_id, new_order.id))
          Repo.insert_all_2(Pczone.OrderItem, items)
        end)
        |> Ecto.Multi.run(:remove_cart_items, fn _, %{} ->
          Repo.delete_all_2(from(i in Pczone.OrderItem, where: i.id in ^item_ids))
        end)
        |> Repo.transaction()
    end
  end

  def transit(
        :submit,
        %Pczone.Order{state: _},
        _params,
        _context
      ) do
    {:error, "We can only submit order in cart state"}
  end

  defp get_tax_info(%{tax_info_id: tax_info_id}) when is_bitstring(tax_info_id) do
    %{tax_info: tax_info} = Repo.get(Pczone.UserTaxInfo, tax_info_id)
    Map.from_struct(tax_info)
  end

  defp get_tax_info(%{tax_info: tax_info = %{}}) do
    tax_info
  end

  defp get_tax_info(_params) do
    nil
  end

  defp get_shipping_address(%{shipping_address_id: shipping_address_id})
       when is_bitstring(shipping_address_id) do
    %{address: address} = Repo.get(Pczone.UserAddress, shipping_address_id)
    Map.from_struct(address)
  end

  defp get_shipping_address(%{shipping_address: shipping_address = %{}}) do
    shipping_address
  end
end