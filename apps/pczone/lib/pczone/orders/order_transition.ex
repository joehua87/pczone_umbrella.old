defmodule Pczone.Orders.Transition do
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Repo, Orders}

  def submit(order_id, params) when is_bitstring(order_id) do
    order = Repo.get(Pczone.Order, order_id)
    submit(order, params)
  end

  def submit(
        %Pczone.Order{state: :cart},
        %{item_ids: [], built_ids: []}
      ) do
    {:error, "Must have at least 1 item or 1 built"}
  end

  def submit(
        %Pczone.Order{state: :cart},
        %{shipping_address_id: nil, shipping_address: nil}
      ) do
    {:error, "Missing shipping address"}
  end

  def submit(
        %Pczone.Order{id: order_id, state: :cart} = order,
        %{item_ids: item_ids, built_ids: built_ids} = params
      ) do
    shipping_address = get_shipping_address(params)
    tax_info = get_tax_info(params)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:order, fn _, _ ->
        Orders.create(%{
          state: :submitted,
          shipping_address: shipping_address,
          tax_info: tax_info,
          user_id: order.user_id,
          customer_id: order.customer_id
        })
      end)
      |> Ecto.Multi.run(:items, fn _, %{order: new_order} ->
        query =
          from i in Pczone.OrderItem,
            where: i.order_id == ^order_id and i.id in ^item_ids,
            select: %{
              id: fragment("gen_random_uuid()"),
              order_id: ^Ecto.UUID.dump!(new_order.id),
              product_id: i.product_id,
              product_name: i.product_name,
              price: i.price,
              quantity: i.quantity,
              amount: i.price * i.quantity,
              inserted_at: i.inserted_at,
              updated_at: i.updated_at
            }

        Repo.insert_all_2(Pczone.OrderItem, query, returning: true)
      end)
      |> Ecto.Multi.run(:builts, fn _, %{order: new_order} ->
        query =
          from i in Pczone.OrderBuilt,
            where: i.order_id == ^order_id and i.id in ^item_ids,
            select: %{
              id: fragment("gen_random_uuid()"),
              order_id: ^Ecto.UUID.dump!(new_order.id),
              built_id: i.built_id,
              built_template_name: i.built_template_name,
              price: i.price,
              quantity: i.quantity,
              amount: i.price * i.quantity,
              inserted_at: i.inserted_at,
              updated_at: i.updated_at
            }

        Repo.insert_all_2(Pczone.OrderBuilt, query, returning: true)
      end)
      |> Ecto.Multi.run(:remove_cart_items, fn _, %{} ->
        Repo.delete_all_2(from(i in Pczone.OrderItem, where: i.id in ^item_ids))
      end)
      |> Ecto.Multi.run(:remove_cart_builts, fn _, %{} ->
        Repo.delete_all_2(from(i in Pczone.OrderBuilt, where: i.id in ^built_ids))
      end)
      |> Ecto.Multi.run(
        :update_order,
        fn _, %{order: new_order, items: {_, items}, builts: {_, builts}} ->
          items_count = length(items)
          builts_count = length(builts)
          items_quantity = items |> Enum.map(& &1.quantity) |> Enum.sum()
          builts_quantity = builts |> Enum.map(& &1.quantity) |> Enum.sum()
          items_total = items |> Enum.map(& &1.amount) |> Enum.sum()
          builts_total = builts |> Enum.map(& &1.amount) |> Enum.sum()
          total = items_total + builts_total

          new_order
          |> Ecto.Changeset.change(%{
            items_count: items_count,
            builts_count: builts_count,
            items_quantity: items_quantity,
            builts_quantity: builts_quantity,
            items_total: items_total,
            builts_total: builts_total,
            total: total
          })
          |> Repo.update()
        end
      )

    with {:ok, %{update_order: order}} <- Repo.transaction(multi) do
      {:ok, order}
    end
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
