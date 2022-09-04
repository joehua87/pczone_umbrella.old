defmodule Pczone.ProductAttributesTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.Products

  describe "product attributes" do
    test "add attribute", %{product: product} do
      attribute_item = Pczone.Repo.one(from Pczone.AttributeItem, limit: 1)

      assert {:ok, %Pczone.ProductAttribute{}} =
               Products.add_attribute(%{
                 product_id: product.id,
                 attribute_item_id: attribute_item.id
               })
    end

    test "add attributes", %{product: product} do
      attribute_items = Pczone.Repo.all(from Pczone.AttributeItem, limit: 5)
      attribute_item_ids = Enum.map(attribute_items, & &1.id)

      assert {:ok, {5, [%Pczone.ProductAttribute{} | _]}} =
               Products.add_attributes(
                 %{product_id: product.id, attribute_item_ids: attribute_item_ids},
                 returning: true
               )
    end

    test "remove attribute", %{product: product} do
      attribute_item = Pczone.Repo.one(from Pczone.AttributeItem, limit: 1)

      assert {:ok, %Pczone.ProductAttribute{}} =
               Products.add_attribute(%{
                 product_id: product.id,
                 attribute_item_id: attribute_item.id
               })

      assert {:ok, %Pczone.ProductAttribute{}} =
               Products.remove_attribute(%{
                 product_id: product.id,
                 attribute_item_id: attribute_item.id
               })
    end

    test "remove attributes", %{product: product} do
      attribute_items = Pczone.Repo.all(from Pczone.AttributeItem, limit: 5)
      attribute_item_ids = Enum.map(attribute_items, & &1.id)

      assert {:ok, {5, [%Pczone.ProductAttribute{} | _]}} =
               Products.add_attributes(
                 %{product_id: product.id, attribute_item_ids: attribute_item_ids},
                 returning: true
               )

      assert {:ok, {5, _}} =
               Products.remove_attributes(%{
                 product_id: product.id,
                 attribute_item_ids: attribute_item_ids
               })
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir()
    |> Pczone.initial_data()

    Pczone.Fixtures.get_fixture_path("attributes.xlsx")
    |> Pczone.Attributes.upsert_from_xlsx()

    assert {:ok, %{products: {38, [%Pczone.Product{} = product | _]}}} =
             Pczone.Fixtures.get_fixture_path("products.xlsx")
             |> Pczone.Xlsx.read_spreadsheet()
             |> Products.upsert()

    {:ok, product: product}
  end
end
