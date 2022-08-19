defmodule Pczone.StoresTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  alias Pczone.{BuiltTemplates, Stores}

  describe "stores" do
    test "upsert built template stores", %{store: store} do
      built_templates_fixture()
      path = get_fixtures_dir() |> Path.join("built_template_stores_shopee.xlsx")

      assert {:ok,
              {2,
               [
                 %Pczone.BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "19301333605",
                   built_template_id: _
                 },
                 %Pczone.BuiltTemplateStore{
                   id: _,
                   store_id: _,
                   product_code: "15618662714",
                   built_template_id: _
                 }
               ]}} = Stores.upsert_built_template_stores(store.id, path, returning: true)
    end

    test "read built template variants from xlsx" do
      path = get_fixtures_dir() |> Path.join("shopee_built_template_variants.xlsx")

      assert [
               %{
                 "id" => 829,
                 "option_values" => "i5-6500T; Ko RAM, Ko SSD",
                 "price" => 3_500_000,
                 "product_code" => "aaa",
                 "product_name" => "Hp Elitedesk 800 G2 Mini",
                 "stock" => 99,
                 "variant_code" => "x1"
               },
               %{
                 "id" => 830,
                 "option_values" => "i5-6500T; Ko RAM, 256GB NVMe 95%",
                 "price" => 4_250_000,
                 "product_code" => "aaa",
                 "product_name" => "Hp Elitedesk 800 G2 Mini",
                 "stock" => 99,
                 "variant_code" => "x2"
               }
               | _
             ] = Stores.read_store_built_template_variants(path)
    end

    test "upsert built template variants", %{store: store} do
      [built_template | _] = built_templates_fixture()

      assert {:ok, {_, built_template_variants}} =
               built_template
               |> BuiltTemplates.generate_variants(returning: true)

      list =
        built_template_variants
        |> Enum.take(4)
        |> Enum.with_index(fn %{id: id}, index ->
          %{
            "id" => id,
            "product_code" => "a",
            "variant_code" => "x-#{index}"
          }
        end)

      assert {:ok, {4, _}} = Stores.upsert_built_template_variants(store.id, list)
    end
  end

  setup do
    get_fixtures_dir() |> Pczone.initial_data()
    {:ok, store: Pczone.Stores.get_by_code("shopee")}
  end
end
