defmodule Pczone.Stores.LazadaTest do
  use Pczone.DataCase, async: true
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures

  describe "lazada store" do
    test "read spreadsheet" do
      path = get_fixtures_dir() |> Path.join("lazada-pricestock.xlsx")

      assert [
               %{
                 product_code: "2028255211",
                 variant_code:
                   "9454850510:2028255211_VNAMZ-9454850510:d26f7b71151b9f9bb979eca4dc6889eb",
                 variant_name: "Ryzen 5 2400GE,16GB + 512GB NVMe"
               },
               %{
                 product_code: "2028255211",
                 variant_code:
                   "9454850509:2028255211_VNAMZ-9454850509:9475a69f26b191b911354016b6572748",
                 variant_name: "Ryzen 5 2400GE,16GB + 256GB NVMe"
               }
               | _
             ] = Pczone.Stores.read_product_variants("lazada", path)
    end

    test "upsert built stores" do
      result = upsert_built_stores()

      assert [
               "8692918491:1907169068_VNAMZ-8692918491:694ad015d33fe79c4a75415814e9e3dc",
               "8692918492:1907169068_VNAMZ-8692918492:8dfc7f87e555ae101e0ffee57d94df95",
               "8692918495:1907169068_VNAMZ-8692918495:ed5e67e6ed957ebe5646250558a1e035",
               "8692918496:1907169068_VNAMZ-8692918496:915d913ce4bbd02ba950ac8213a308a7",
               "8692918497:1907169068_VNAMZ-8692918497:48b2dcc53ef7f13c9d67d318a38152ef",
               "8692918498:1907169068_VNAMZ-8692918498:af19ac576416b7420cfc337963f04799",
               "9463370872:1907169068_VNAMZ-9463370872:473f43b281ece9f1baf1c2c565117f63",
               "9463370873:1907169068_VNAMZ-9463370873:35d3e5d1b14568d98f777ddaec0056f1",
               "9463370874:1907169068_VNAMZ-9463370874:fcf68661af6fcd0481c79915c47c2f2a",
               "9463370875:1907169068_VNAMZ-9463370875:0ce0bba7343b81ff0774093d9e0427b5",
               "9463370876:1907169068_VNAMZ-9463370876:ee8d91d70652b31c78f2bdd48285391e",
               "9463370877:1907169068_VNAMZ-9463370877:a48d4cc81635a7225f1d51f0f2429256"
             ] = result |> Enum.map(& &1.variant_code) |> Enum.sort()
    end

    test "make pricing workbook" do
      upsert_built_stores()
      store = Pczone.Repo.one(from Pczone.Store, where: [code: "lazada"])
      workbook = Pczone.Stores.make_pricing_workbook(store)

      assert %Elixlsx.Workbook{
               datetime: nil,
               sheets: [
                 %Elixlsx.Sheet{
                   name: "Sheet1",
                   rows: [
                     [
                       "Product ID",
                       "catId",
                       "Tên sản phẩm",
                       "currencyCode",
                       "sku.skuId",
                       "Variations Combo",
                       "Lazada SKU",
                       "status",
                       "SpecialPrice",
                       "SpecialPrice Start",
                       "SpecialPrice End",
                       "Giá",
                       "SellerSku",
                       "Kho hàng",
                       "tr(s-wb-product@md5key)"
                     ],
                     [],
                     [],
                     [],
                     ["1907169068" | _]
                     | _
                   ],
                   col_widths: %{},
                   row_heights: %{},
                   merge_cells: [],
                   pane_freeze: nil,
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
    store = Pczone.Repo.one(from Pczone.Store, where: [code: "lazada"])

    # Sync built template stores product code
    built_template_stores_path =
      get_fixtures_dir() |> Path.join("built_template_stores_lazada.xlsx")

    Pczone.BuiltTemplateStores.upsert_from_xlsx(built_template_stores_path)

    # Generate builts
    built_template = Enum.find(built_templates, &(&1.code == "hp-elitedesk-800-g2-mini-65w"))
    Pczone.BuiltTemplates.generate_builts(built_template)

    # Sync built stores variant codes
    path = get_fixtures_dir() |> Path.join("lazada-pricestock.xlsx")
    assert {:ok, {12, result}} = Pczone.Stores.upsert_built_stores(store, path, returning: true)
    result
  end
end
