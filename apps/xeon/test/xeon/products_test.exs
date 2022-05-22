defmodule Xeon.ProductsTest do
  use Xeon.DataCase
  alias Xeon.Products

  describe "products" do
    test "upsert" do
      Xeon.Fixtures.get_fixtures_dir() |> Xeon.initial_data()
      products = Xeon.Fixtures.read_fixture("products.yml")

      assert {27,
              [
                %Xeon.Product{
                  barebone_id: _,
                  condition: "Used",
                  id: _,
                  sale_price: 1_800_000,
                  sku: "hp-elitedesk-800-g2-mini/used",
                  slug: "hp-elitedesk-800-g2-mini-used",
                  stock: 10,
                  title: "HP EliteDesk 800 G2 Mini (Used)",
                  type: nil
                }
                | _
              ]} = Products.upsert(products, returning: true)
    end
  end
end
