defmodule Pczone.ProductsTest do
  use Pczone.DataCase
  alias Pczone.Products

  describe "products" do
    test "upsert" do
      Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
      products = Pczone.Fixtures.read_fixture("products.xlsx")

      assert {:ok,
              %{
                products: {38, [%Pczone.Product{} | _]}
              }} = Products.upsert(products)
    end

    test "upsert from xlsx" do
      Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()

      assert {:ok,
              %{
                products: {38, [%Pczone.Product{} | _]}
              }} =
               Pczone.Fixtures.get_fixtures_dir()
               |> Path.join("products.xlsx")
               |> Pczone.Xlsx.read_spreadsheet()
               |> Products.upsert()
    end
  end
end
