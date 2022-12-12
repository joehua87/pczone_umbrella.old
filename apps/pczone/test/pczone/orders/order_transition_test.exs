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

      assert {:error, "Must have at least 1 item or 1 built"} =
               Orders.Transition.submit(
                 order,
                 %{item_ids: [], built_ids: [], shipping_address: address_fixture()}
               )
    end

    test "submit order" do
      product = get_product()
      assert {:ok, order} = Orders.create()
      context = %{order_token: order.token}

      assert {:ok, %Pczone.OrderItem{id: order_item_id}} =
               Orders.add_item(%{product_id: product.id, quantity: 1}, context)

      assert {:ok,
              %Pczone.Order{
                id: _,
                shipping_address: %{
                  first_name: "Dew",
                  last_name: "John",
                  full_name: "Dew John"
                },
                items_count: 1,
                builts_count: 0,
                items_quantity: 1,
                builts_quantity: 0,
                items_total: 1_900_000,
                builts_total: 0,
                total: 1_900_000,
                state: :submitted
              }} =
               Orders.Transition.submit(
                 order,
                 %{item_ids: [order_item_id], built_ids: [], shipping_address: address_fixture()}
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
