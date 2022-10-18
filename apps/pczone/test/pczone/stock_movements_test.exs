defmodule Pczone.StockMovementsTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Repo, Product, ProductStock, StockMovements}

  describe "stock movements" do
    test "create" do
      {:ok, %{id: stock_movement_id, state: :created}} = StockMovements.create()

      assert {:ok, %Pczone.StockMovementItem{}} =
               stock_movement_id
               |> get_item_params()
               |> StockMovements.add_item()
    end

    test "add items" do
      {:ok, %{id: stock_movement_id, state: :created}} = StockMovements.create()
      items = get_items_params(stock_movement_id)
      assert {:ok, {2, _}} = StockMovements.add_items(items)
      StockMovements.add_items(items)
    end

    test "add duplicated items" do
      {:ok, %{id: stock_movement_id, state: :created}} = StockMovements.create()
      items = get_items_params(stock_movement_id)
      assert {:ok, {2, _}} = StockMovements.add_items(items)
      assert {:ok, {2, _}} = StockMovements.add_items(items)
    end

    test "submit" do
      {:ok, %{id: stock_movement_id, state: :created}} = StockMovements.create()

      stock_movement_id
      |> get_item_params()
      |> StockMovements.add_item()

      assert {:ok, %{stock_movement: %{state: :submitted}, items: _}} =
               StockMovements.submit(stock_movement_id)

      assert [
               %Pczone.ProductStock{
                 code: "xx",
                 product_id: _,
                 quantity: 1,
                 location: "A.1"
               }
             ] = Repo.all(ProductStock)
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
    :ok
  end

  defp get_product() do
    Repo.one(from Product, where: [code: "dell-optiplex-7040-sff/like-new"], limit: 1)
  end

  defp get_item_params(stock_movement_id, product \\ nil) do
    product = product || get_product()

    %{
      code: "xx",
      product_id: product.id,
      quantity: 1,
      stock_movement_id: stock_movement_id,
      source_location: "external",
      destination_location: "A.1"
    }
  end

  defp get_items_params(stock_movement_id) do
    product = get_product()

    [
      %{get_item_params(stock_movement_id, product) | code: "aa"},
      %{get_item_params(stock_movement_id, product) | code: "bb"}
    ]
  end
end
