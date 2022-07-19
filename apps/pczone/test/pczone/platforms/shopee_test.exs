defmodule Pczone.Platforms.ShopeeTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures

  describe "shopee platform" do
    test "read spreadsheet" do
      path = get_fixtures_dir() |> Path.join("mass_update_sales_info.xlsx")

      assert [
               %{
                 product_code: "19301333605",
                 variant_code: "38950760545",
                 variant_name: "i5-6500,16GB + 128GB NVMe"
               },
               %{
                 product_code: "19301333605",
                 variant_code: "38950760546",
                 variant_name: "i5-6500,16GB + 256GB NVMe"
               }
               | _
             ] = Pczone.Platforms.read_product_variants("shopee", path)
    end

    test "upsert simple built variant platforms" do
      # Initial data
      get_fixtures_dir() |> Pczone.initial_data()
      simple_builts = simple_builts_fixture()
      platform = Pczone.Repo.one(from Pczone.Platform, where: [code: "shopee"])

      # Sync simple built platforms product code
      simple_built_platforms_path =
        get_fixtures_dir() |> Path.join("simple_built_platforms_shopee.xlsx")

      Pczone.Platforms.upsert_simple_built_platforms(platform.id, simple_built_platforms_path)

      # Generate simple built variants
      simple_built = Enum.find(simple_builts, &(&1.code == "hp-elitedesk-800-g2-mini-65w"))
      Pczone.SimpleBuilts.generate_variants(simple_built)

      # Sync simple built variant platforms variant codes
      path = get_fixtures_dir() |> Path.join("mass_update_sales_info.xlsx")

      assert {:ok, {6, result}} =
               Pczone.Platforms.upsert_simple_built_variant_platforms(platform, path,
                 returning: true
               )

      assert [
               "210076422096",
               "210076422100",
               "38950760549",
               "38950760551",
               "38950760552",
               "38950760553"
             ] = result |> Enum.map(& &1.variant_code) |> Enum.sort()
    end
  end
end
