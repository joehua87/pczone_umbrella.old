defmodule Pczone.Stores.ShopeeTest do
  use Pczone.DataCase, async: true
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures

  describe "shopee store" do
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
             ] = Pczone.Stores.read_product_variants("shopee", path)
    end

    test "upsert built stores" do
      result = upsert_built_stores()

      assert [
               "210076422096",
               "210076422100",
               "38950760549",
               "38950760551",
               "38950760552",
               "38950760553"
             ] = result |> Enum.map(& &1.variant_code) |> Enum.sort()
    end

    test "make pricing workbook" do
      upsert_built_stores()
      store = Pczone.Repo.one(from Pczone.Store, where: [code: "shopee"])
      workbook = Pczone.Stores.make_pricing_workbook(store)

      assert %Elixlsx.Workbook{
               datetime: nil,
               sheets: [
                 %Elixlsx.Sheet{
                   col_widths: %{},
                   merge_cells: [],
                   name: "Sheet1",
                   pane_freeze: nil,
                   row_heights: %{},
                   rows: [
                     [
                       "et_title_product_id",
                       "et_title_product_name",
                       "et_title_variation_id",
                       "et_title_variation_name",
                       "et_title_parent_sku",
                       "et_title_variation_sku",
                       "et_title_variation_price",
                       "et_title_variation_stock",
                       "et_title_reason"
                     ],
                     ["sales_info", "220408_floatingstock"],
                     [
                       nil,
                       nil,
                       nil,
                       nil,
                       nil,
                       nil,
                       "Giá của sản phẩm đắt nhất chia cho giá của giới hạn sản phẩm rẻ nhất: 5",
                       nil
                     ],
                     [
                       "Mã Sản phẩm",
                       "Tên Sản phẩm",
                       "Mã Phân loại",
                       "Tên phân loại",
                       "SKU Sản phẩm",
                       "SKU",
                       "Giá",
                       "Số lượng"
                     ],
                     ["19301333605" | _],
                     ["19301333605" | _],
                     ["19301333605" | _],
                     ["19301333605" | _],
                     ["19301333605" | _],
                     ["19301333605" | _]
                   ],
                   show_grid_lines: true
                 }
               ]
             } = workbook
    end
  end

  defp upsert_built_stores() do
    # Initial data
    get_fixtures_dir() |> Pczone.initial_data()
    built_templates = built_templates_fixture()
    store = Pczone.Repo.one(from Pczone.Store, where: [code: "shopee"])

    # Sync built template stores product code
    built_template_stores_path =
      get_fixtures_dir() |> Path.join("built_template_stores_shopee.xlsx")

    Pczone.BuiltTemplateStores.upsert_from_xlsx(built_template_stores_path)

    # Generate builts
    built_template = Enum.find(built_templates, &(&1.code == "hp-elitedesk-800-g2-mini-65w"))
    Pczone.BuiltTemplates.generate_builts(built_template)

    # Sync built stores variant codes
    path = get_fixtures_dir() |> Path.join("mass_update_sales_info.xlsx")

    assert {:ok, {6, result}} = Pczone.Stores.upsert_built_stores(store, path, returning: true)

    result
  end
end
