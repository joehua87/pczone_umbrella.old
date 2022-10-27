defmodule Pczone.OrdersTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Orders, Product, Repo}

  describe "orders" do
    test "create" do
      assert {:ok, %{code: code}} = Orders.create()
      assert String.length(code) == 14
    end

    test "add order item" do
      product = get_product()
      assert {:ok, order} = Orders.create()

      assert {:ok,
              %Pczone.OrderItem{
                order_id: _,
                product_id: _,
                from_built: false,
                price: 1_900_000,
                quantity: 1,
                amount: 1_900_000
              }} =
               Orders.add_item(%{product_id: product.id, quantity: 1}, %{order_token: order.token})
    end

    test "update order item" do
      product = get_product()
      assert {:ok, order} = Orders.create()

      assert {:ok, _} =
               Orders.add_item(%{product_id: product.id, quantity: 1}, %{order_token: order.token})

      assert {:ok,
              %Pczone.OrderItem{
                price: 1_900_000,
                quantity: 2,
                amount: 3_800_000
              }} =
               Orders.update_item(%{product_id: product.id, quantity: 2}, %{
                 order_token: order.token
               })
    end

    test "remove order item" do
      product = get_product()
      assert {:ok, order} = Orders.create()

      assert {:ok, _} =
               Orders.add_item(%{product_id: product.id, quantity: 1}, %{order_token: order.token})

      assert {:ok, %Pczone.OrderItem{price: 1_900_000, quantity: 1}} =
               Orders.remove_item(%{product_id: product.id}, %{order_token: order.token})

      assert %{items: []} =
               Repo.one(from o in Pczone.Order, preload: [:items], where: o.id == ^order.id)
    end

    test "add order built" do
      built = get_built()
      assert {:ok, order} = Orders.create()

      assert {:ok,
              %{
                order_id: _,
                built_id: _,
                price: 5_320_000,
                quantity: 1,
                amount: 5_320_000,
                inserted_at: _,
                updated_at: _
              }} = Orders.add_built(%{order_id: order.id, built_id: built.id, quantity: 1})
    end

    test "update order built" do
      built = get_built()
      assert {:ok, order} = Orders.create()
      assert {:ok, _} = Orders.add_built(%{order_id: order.id, built_id: built.id, quantity: 1})

      assert {:ok,
              %{
                order_id: _,
                built_id: _,
                price: 5_320_000,
                quantity: 2,
                amount: 10_640_000,
                inserted_at: _,
                updated_at: _
              }} = Orders.update_built(%{order_id: order.id, built_id: built.id, quantity: 2})
    end

    test "remove order built" do
      built = get_built()
      assert {:ok, order} = Orders.create()
      assert {:ok, _} = Orders.add_built(%{order_id: order.id, built_id: built.id, quantity: 1})

      assert {:ok,
              %{
                price: 5_320_000,
                quantity: 1
              }} = Orders.remove_built(%{order_id: order.id, built_id: built.id})

      assert %{builts: []} =
               Repo.one(from o in Pczone.Order, preload: [:builts], where: o.id == ^order.id)
    end

    test "submit order with no items" do
      product = get_product()
      assert {:ok, order} = Orders.create()
      context = %{order_token: order.token}
      assert {:ok, _} = Orders.add_item(%{product_id: product.id, quantity: 1}, context)

      assert {:error, "Item ids must be more than 1"} =
               Orders.submit(%{item_ids: [], shipping_address: address_fixture()}, context)
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
               Orders.submit(
                 %{item_ids: [order_item_id], shipping_address: address_fixture()},
                 context
               )

      assert %{paging: %{total_entities: 0}} = Orders.get_cart_items(context)
    end

    test "approve order" do
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
    :ok
  end

  defp get_product() do
    Repo.one(from Product, where: [code: "dell-optiplex-7040-sff/like-new"], limit: 1)
  end

  defp get_built() do
    Repo.one(from Product, where: [code: "dell-optiplex-7040-sff/like-new"], limit: 1)
    [built_template | _] = built_templates_fixture()
    assert {:ok, _} = Pczone.BuiltTemplates.generate_builts(built_template)
    Repo.one(from Pczone.Built, where: [slug: "i5-6500t-8gb-512gb-nvme"])
  end
end
