defmodule Pczone.Orders.OrderTransitionTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Orders, Product, Repo}

  describe "order transition" do
    test "submit order with no items" do
      product = get_product()
      assert {:ok, order} = Orders.create()
      context = %{order_token: order.token}
      assert {:ok, _} = Orders.add_item(%{product_id: product.id, quantity: 1}, context)

      assert {:error, "Item ids must be more than 1"} =
               Orders.Transition.transit(
                 :submit,
                 order.id,
                 %{item_ids: [], shipping_address: address_fixture()},
                 context
               )
    end

    test "submit order" do
      product = get_product()
      assert {:ok, order} = Orders.create()
      context = %{order_token: order.token}

      assert {:ok, %Pczone.OrderItem{id: order_item_id}} =
               Orders.add_item(%{product_id: product.id, quantity: 1}, context)

      assert {:ok,
              %{
                items: {1, nil},
                order: %Pczone.Order{
                  id: _,
                  shipping_address: %{
                    first_name: "Dew",
                    last_name: "John",
                    full_name: "Dew John"
                  },
                  total: 1_900_000,
                  state: :submitted
                },
                remove_cart_items: {1, nil}
              }} =
               Orders.Transition.transit(
                 :submit,
                 order.id,
                 %{item_ids: [order_item_id], shipping_address: address_fixture()},
                 context
               )

      assert %{items: [], builts: []} =
               Orders.get_cart(context) |> Repo.preload([:items, :builts])
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
    :ok
  end

  defp get_product() do
    Repo.one(from Product, where: [code: "dell-optiplex-7040-sff/like-new"], limit: 1)
  end
end
