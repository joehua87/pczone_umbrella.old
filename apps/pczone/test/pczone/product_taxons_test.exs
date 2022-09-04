defmodule Pczone.ProductTaxonomiesTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.Products

  describe "product taxonomies" do
    test "add taxonomy", %{product: product} do
      taxon = Pczone.Repo.one(from Pczone.Taxon, limit: 1)

      assert {:ok, %Pczone.ProductTaxon{}} =
               Products.add_taxonomy(%{
                 product_id: product.id,
                 taxon_id: taxon.id
               })
    end

    test "add taxonomies", %{product: product} do
      taxons = Pczone.Repo.all(from Pczone.Taxon, limit: 5)
      taxon_ids = Enum.map(taxons, & &1.id)

      assert {:ok, {5, [%Pczone.ProductTaxon{} | _]}} =
               Products.add_taxonomies(
                 %{product_id: product.id, taxon_ids: taxon_ids},
                 returning: true
               )
    end

    test "remove taxonomy", %{product: product} do
      taxon = Pczone.Repo.one(from Pczone.Taxon, limit: 1)

      assert {:ok, %Pczone.ProductTaxon{}} =
               Products.add_taxonomy(%{
                 product_id: product.id,
                 taxon_id: taxon.id
               })

      assert {:ok, %Pczone.ProductTaxon{}} =
               Products.remove_taxonomy(%{
                 product_id: product.id,
                 taxon_id: taxon.id
               })
    end

    test "remove taxonomies", %{product: product} do
      taxons = Pczone.Repo.all(from Pczone.Taxon, limit: 5)
      taxon_ids = Enum.map(taxons, & &1.id)

      assert {:ok, {5, [%Pczone.ProductTaxon{} | _]}} =
               Products.add_taxonomies(
                 %{product_id: product.id, taxon_ids: taxon_ids},
                 returning: true
               )

      assert {:ok, {5, _}} =
               Products.remove_taxonomies(%{
                 product_id: product.id,
                 taxon_ids: taxon_ids
               })
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir()
    |> Pczone.initial_data()

    Pczone.Fixtures.get_fixture_path("taxonomies.xlsx")
    |> Pczone.Taxonomies.upsert_from_xlsx()

    assert {:ok, %{products: {38, [%Pczone.Product{} = product | _]}}} =
             Pczone.Fixtures.get_fixture_path("products.xlsx")
             |> Pczone.Xlsx.read_spreadsheet()
             |> Products.upsert()

    {:ok, product: product}
  end
end
