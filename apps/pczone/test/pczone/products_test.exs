defmodule Pczone.ProductsTest do
  use Pczone.DataCase
  alias Pczone.Products

  describe "products" do
    test "upsert" do
      products = Pczone.Fixtures.read_fixture("products.xlsx")

      assert {:ok,
              %{
                products: {38, [%Pczone.Product{} | _]}
              }} = Products.upsert(products)
    end

    test "upsert from xlsx" do
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

  setup do
    Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
    :ok
  end
end
