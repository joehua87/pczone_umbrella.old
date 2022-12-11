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

  def get(id) do
    Repo.get(Pczone.Order, id)
  end

  def get_cart(context = %{user_id: "" <> user_id}) do
    case Repo.one(from Pczone.Order, where: [user_id: ^user_id, state: :cart]) do
      nil ->
        {:ok, order} = create(context)
        order

      %{} = order ->
        order
    end
  end

  def get_cart(context = %{order_token: "" <> order_token}) do
    case Repo.one(from Pczone.Order, where: [token: ^order_token, state: :cart]) do
      nil ->
        {:ok, order} = create(context)
        order

      %{} = order ->
        order
    end
  end

  def get_cart(_context) do
    nil
  end

  def create(params \\ %{}, context \\ %{})

  def create(params, context) do
    user_id =
      case context do
        %{user_id: user_id} -> user_id
        _ -> nil
      end

    code = generate_code()
    token = generate_token()

    %{code: code, token: token, user_id: user_id}
    |> Map.merge(params)
    |> Pczone.Order.new_changeset()
    |> Repo.insert()
  end

  def ensure_cart(context) do
    case get_cart(context) do
      %{} = order ->
        order

      _ ->
        {:ok, order} = create()
        order
    end
  end

  def approve() do
    # TODO: Add stock_movement
  end

  def add_built(%{built_id: built_id, quantity: quantity}, context) do
    order = ensure_cart(context)
    %{price: price, name: built_template_name} = Pczone.Builts.get(built_id)

    %{
      order_id: order.id,
      built_id: built_id,
      built_template_name: built_template_name,
      price: price,
      quantity: quantity,
      amount: price * quantity
    }
    |> Pczone.OrderBuilt.new_changeset()
    |> Repo.insert(
      on_conflict: [
        set: [price: price],
        inc: [quantity: quantity, amount: price * quantity]
      ],
      conflict_target: [:order_id, :built_id]
    )
  end

  def update_built(%{built_id: built_id, quantity: quantity}, context) do
    order = ensure_cart(context)

    with %Pczone.OrderBuilt{} = order_item <-
           Repo.one(from Pczone.OrderBuilt, where: [order_id: ^order.id, built_id: ^built_id]) do
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

  def remove_built(%{built_id: built_id}, context) do
    order = ensure_cart(context)

    with %Pczone.OrderBuilt{} = order_built <-
           Repo.one(from Pczone.OrderBuilt, where: [order_id: ^order.id, built_id: ^built_id]) do
      order_built
      |> Pczone.OrderBuilt.changeset(%{})
      |> Repo.delete()
    end
  end

  def add_item(%{product_id: product_id, quantity: quantity}, context) do
    order = ensure_cart(context)
    %{sale_price: price, title: product_name} = Products.get(product_id)

    %{
      order_id: order.id,
      product_id: product_id,
      product_name: product_name,
      price: price,
      quantity: quantity,
      amount: price * quantity
    }
    |> Pczone.OrderItem.new_changeset()
    |> Repo.insert(
      on_conflict: [
        set: [price: price, product_name: product_name],
        inc: [quantity: quantity, amount: price * quantity]
      ],
      conflict_target: [:order_id, :product_id]
    )
  end

  def update_item(%{product_id: product_id, quantity: quantity}, context) do
    order = ensure_cart(context)

    with %Pczone.OrderItem{} = order_item <-
           Repo.one(from Pczone.OrderItem, where: [order_id: ^order.id, product_id: ^product_id]) do
      %{sale_price: price} = Products.get(product_id)

      order_item
      |> Pczone.OrderItem.changeset(%{
        price: price,
        quantity: quantity,
        amount: price * quantity
      })
      |> Repo.update()
    end
  end

  def remove_item(%{product_id: product_id}, context) do
    order = ensure_cart(context)

    with %Pczone.OrderItem{} = order_item <-
           Repo.one(from Pczone.OrderItem, where: [order_id: ^order.id, product_id: ^product_id]) do
      order_item
      |> Pczone.OrderItem.changeset(%{})
      |> Repo.delete()
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
