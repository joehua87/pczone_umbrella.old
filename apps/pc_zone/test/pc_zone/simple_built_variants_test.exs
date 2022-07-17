defmodule PcZone.SimpleBuiltVariantsTest do
  use PcZone.DataCase
  import PcZone.Fixtures
  alias PcZone.{SimpleBuilts, SimpleBuiltVariants}

  describe "simple built variants" do
    test "generate report" do
      [simple_built | _] = simple_builts_fixture()

      assert {_, _} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants()

      assert %Elixlsx.Workbook{
               datetime: nil,
               sheets: [
                 %Elixlsx.Sheet{
                   col_widths: %{},
                   merge_cells: [],
                   name: "Products",
                   pane_freeze: nil,
                   row_heights: %{},
                   rows: [
                     [
                       "id",
                       "product_name",
                       "product_code",
                       "variant_code",
                       "option_values",
                       "price",
                       "stock"
                     ],
                     #  [
                     #    "Id",
                     #    "Tên Sản phẩm",
                     #    "Mã Sản phẩm",
                     #    "Mã Phân loại",
                     #    "Tên phân loại",
                     #    "Giá",
                     #    "Số lượng"
                     #  ],
                     [
                       _,
                       "Hp Elitedesk 800 G2 Mini",
                       "",
                       "",
                       "i5-6500T; Không RAM, Không SSD",
                       3_500_000,
                       99
                     ]
                     | _
                   ]
                 }
               ]
             } = SimpleBuiltVariants.generate_report()
    end

    test "export csv" do
      [simple_built] = simple_builts_fixture()

      assert {_, _} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants()

      assert {
               :ok,
               %PcZone.Report{
                 category: "simple-built-variant",
                 name: "simple-built-variants" <> _,
                 path: _,
                 type: "xlsx",
                 size: _,
                 updated_at: _
               } = report
             } = SimpleBuiltVariants.export_csv()

      report
      |> PcZone.Reports.get_report_absolute_path()
      |> File.rm!()
    end
  end

  setup do
    get_fixtures_dir() |> PcZone.initial_data()
    :ok
  end
end
