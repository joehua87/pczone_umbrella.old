defmodule PcZone.ProductsTest do
  use PcZone.DataCase
  alias PcZone.Products

  describe "products" do
    test "upsert" do
      PcZone.Fixtures.get_fixtures_dir() |> PcZone.initial_data()
      products = PcZone.Fixtures.read_fixture("products.xlsx")

      assert {32,
              [
                %PcZone.Product{}
                | _
              ]} = Products.upsert(products, returning: true)
    end

    test "upsert from xlsx" do
      PcZone.Fixtures.get_fixtures_dir() |> PcZone.initial_data()

      assert {32,
              [
                %PcZone.Product{
                  barebone_id: _,
                  category_id: _,
                  chassis_id: _,
                  condition: "Used",
                  cost: nil,
                  gpu_id: _,
                  hard_drive_id: _,
                  heatsink_id: _,
                  id: _,
                  list_price: nil,
                  memory_id: _,
                  motherboard_id: _,
                  processor_id: _,
                  psu_id: _,
                  sale_price: 1_800_000,
                  sku: "dell-optiplex-7040-sff/used",
                  slug: "dell-optiplex-7040-sff-used",
                  stock: 10,
                  title: "Dell OptiPlex 7040 SFF (Used)",
                  type: nil
                }
                | _
              ]} =
               PcZone.Fixtures.get_fixtures_dir()
               |> Path.join("products.xlsx")
               |> PcZone.Xlsx.read_spreadsheet()
               |> Products.upsert(returning: true)
    end
  end
end
