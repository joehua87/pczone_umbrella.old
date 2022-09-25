defmodule Pczone.Orders do
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Repo, Builts, Products}

  def get(context = %{user: %{id: user_id}}) do
    case Repo.one(from Pczone.Order, where: [user_id: ^user_id, state: :cart]) do
      nil ->
        {:ok, order} = create(context)
        order

      %{} = order ->
        order
    end
  end

  def get(context = %{order_token: order_token}) do
    case Repo.one(from Pczone.Order, where: [token: ^order_token, state: :cart]) do
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
    Repo.paginate(from i in Pczone.OrderItem, where: i.order_id == ^order.id)
  end

  def create(context \\ %{})

  def create(context) do
    user_id =
      case context do
        %{user: %{id: user_id}} -> user_id
        _ -> nil
      end

    code = generate_code()
    token = generate_token()
    %{code: code, token: token, user_id: user_id} |> Pczone.Order.new_changeset() |> Repo.insert()
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
           Repo.one(from Pczone.OrderBuilt, where: [order_id: ^order_id, built_id: ^built_id]) do
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
           Repo.one(from Pczone.OrderBuilt, where: [order_id: ^order_id, built_id: ^built_id]) do
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
           Repo.one(from Pczone.OrderItem, where: [order_id: ^order_id, product_id: ^product_id]) do
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
           Repo.one(from Pczone.OrderItem, where: [order_id: ^order_id, product_id: ^product_id]) do
      order_item
      |> Pczone.OrderItem.changeset(%{})
      |> Repo.delete()
    else
      %{id: _} ->
        {:error, "Invalid order"}
    end
  end

  def generate_code() do
    date = Timex.now("Asia/Ho_Chi_Minh") |> Timex.format!("{YYYY}{0M}{D}")
    rand = for _ <- 1..6, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxzy')>>
    "#{date}#{rand}"
  end

  def generate_token(bytes \\ 64) do
    :crypto.strong_rand_bytes(bytes) |> Base.url_encode64()
  end
end
