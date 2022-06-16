defmodule PcZone.ProductsTest do
  use PcZone.DataCase
  alias PcZone.Products

  describe "products" do
    test "upsert" do
      PcZone.Fixtures.get_fixtures_dir() |> PcZone.initial_data()
      products = PcZone.Fixtures.read_fixture("products.yml")

      assert {31,
              [
                %PcZone.Product{

                }
                | _
              ]} = Products.upsert(products, returning: true)
    end
  end
end
