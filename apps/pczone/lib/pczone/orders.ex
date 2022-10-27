defmodule Pczone.Orders do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, Builts, Products}

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Order
    |> where(^parse_filter(filter))
    |> select_fields(selection, [:shipping_address, :tax_info])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def get(context = %{user: %{id: user_id}}) do
    case Repo.one(from(Pczone.Order, where: [user_id: ^user_id, state: :cart])) do
      nil ->
        {:ok, order} = create(context)
        order

      %{} = order ->
        order
    end
  end

  def get(context = %{order_token: "" <> order_token}) do
    case Repo.one(from(Pczone.Order, where: [token: ^order_token, state: :cart])) do
      nil ->
        {:ok, order} = create(context)
        order

      %{} = order ->
        order
    end
  end

  def get(_context) do
    {:ok, order} = create()
    order
  end

  def get_cart_items(context) do
    order = get(context)
    Repo.paginate(from(i in Pczone.OrderItem, where: i.order_id == ^order.id))
  end

  def create(context \\ %{}, params \\ %{})

  def create(context, params) do
    user_id =
      case context do
        %{user: %{id: user_id}} -> user_id
        _ -> nil
      end

    code = generate_code()
    token = generate_token()

    %{code: code, token: token, user_id: user_id}
    |> Map.merge(params)
    |> Pczone.Order.new_changeset()
    |> Repo.insert()
  end

  def submit(%{item_ids: item_ids} = params, context) do
    order = get(context)
    shipping_address = get_shipping_address(params)
    tax_info = get_tax_info(params)

    items =
      Repo.all(from(i in Pczone.OrderItem, where: i.order_id == ^order.id and i.id in ^item_ids))

    case items do
      [] ->
        {:error, "Item ids must be more than 1"}

      _ ->
        products_price_map = items |> Enum.map(& &1.product_id) |> Products.get_price_map()

        Ecto.Multi.new()
        |> Ecto.Multi.run(:order, fn _, _ ->
          # TODO: Add billing address, shipping address, state, tax_info
          create(
            context,
            %{state: :submitted, shipping_address: shipping_address, tax_info: tax_info}
          )
        end)
        |> Ecto.Multi.run(:items, fn _, %{order: order} ->
          items =
            Enum.map(items, fn %{product_id: product_id, quantity: quantity} ->
              price = products_price_map[product_id]
              now = DateTime.utc_now() |> DateTime.truncate(:second)

              %{
                order_id: order.id,
                product_id: product_id,
                price: price,
                quantity: quantity,
                amount: price * quantity,
                inserted_at: now,
                updated_at: now
              }
            end)

          Repo.insert_all_2(Pczone.OrderItem, items)
        end)
        |> Ecto.Multi.run(:remove_cart_items, fn _, %{} ->
          Repo.delete_all_2(from(i in Pczone.OrderItem, where: i.id in ^item_ids))
        end)
        |> Repo.transaction()
    end
  end

  def approve() do
    # TODO: Add stock_movement
  end

  def add_built(%{order_id: order_id, built_id: built_id, quantity: quantity}) do
    %{price: price} = Pczone.Builts.get(built_id)

    %{
      order_id: order_id,
      built_id: built_id,
      price: price,
      quantity: quantity,
      amount: price * quantity
    }
    |> Pczone.OrderBuilt.new_changeset()
    |> Repo.insert()
  end

  def update_built(%{order_id: order_id, built_id: built_id, quantity: quantity}) do
    with %Pczone.OrderBuilt{} = order_item <-
           Repo.one(from(Pczone.OrderBuilt, where: [order_id: ^order_id, built_id: ^built_id])) do
      %{price: price} = Builts.get(built_id)

      order_item
      |> Pczone.OrderBuilt.changeset(%{
        price: price,
        quantity: quantity,
        amount: price * quantity
      })
      |> Repo.update()
    end
  end

  def remove_built(%{order_id: order_id, built_id: built_id}) do
    with %Pczone.OrderBuilt{} = order_built <-
           Repo.one(from(Pczone.OrderBuilt, where: [order_id: ^order_id, built_id: ^built_id])) do
      order_built
      |> Pczone.OrderBuilt.changeset(%{})
      |> Repo.delete()
    end
  end

  def add_item(%{product_id: product_id, quantity: quantity}, context) do
    with %{id: order_id, state: :cart} <- get(context) do
      %{sale_price: price} = Products.get(product_id)

      %{
        order_id: order_id,
        product_id: product_id,
        price: price,
        quantity: quantity,
        amount: price * quantity
      }
      |> Pczone.OrderItem.new_changeset()
      |> Repo.insert()
    else
      %{id: _} ->
        {:error, "Invalid order"}
    end
  end

  def update_item(%{product_id: product_id, quantity: quantity}, context) do
    with %{id: order_id, state: :cart} <- get(context),
         %Pczone.OrderItem{} = order_item <-
           Repo.one(from(Pczone.OrderItem, where: [order_id: ^order_id, product_id: ^product_id])) do
      %{sale_price: price} = Products.get(product_id)

      order_item
      |> Pczone.OrderItem.changeset(%{
        price: price,
        quantity: quantity,
        amount: price * quantity
      })
      |> Repo.update()
    else
      %{id: _} ->
        {:error, "Invalid order"}
    end
  end

  def remove_item(%{product_id: product_id}, context) do
    with %{id: order_id, state: :cart} <- get(context),
         %Pczone.OrderItem{} = order_item <-
           Repo.one(from(Pczone.OrderItem, where: [order_id: ^order_id, product_id: ^product_id])) do
      order_item
      |> Pczone.OrderItem.changeset(%{})
      |> Repo.delete()
    else
      %{id: _} ->
        {:error, "Invalid order"}
    end
  end

  def generate_code() do
    date = Timex.now("Asia/Ho_Chi_Minh") |> Timex.format!("{ISOdate}") |> String.replace("-", "")
    rand = for _ <- 1..6, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxzy')>>
    "#{date}#{rand}"
  end

  def generate_token(bytes \\ 64) do
    :crypto.strong_rand_bytes(bytes) |> Base.url_encode64()
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

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :state -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
