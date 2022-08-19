defmodule Pczone.StoresTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  alias Pczone.{SimpleBuilts, Stores}

  describe "stores" do
    test "upsert simple built stores", %{store: store} do
      simple_builts_fixture()
      path = get_fixtures_dir() |> Path.join("simple_built_stores_shopee.xlsx")

      assert {:ok,
              {2,
               [
                 %Pczone.SimpleBuiltStore{
                   id: _,
                   store_id: _,
                   product_code: "19301333605",
                   simple_built_id: _
                 },
                 %Pczone.SimpleBuiltStore{
                   id: _,
                   store_id: _,
                   product_code: "15618662714",
                   simple_built_id: _
                 }
               ]}} = Stores.upsert_simple_built_stores(store.id, path, returning: true)
    end

    test "read simple built variants from xlsx" do
      path = get_fixtures_dir() |> Path.join("shopee-simple-built-variants.xlsx")

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
             ] = Stores.read_store_simple_built_variants(path)
    end

    test "upsert simple built variants", %{store: store} do
      [simple_built | _] = simple_builts_fixture()

      assert {:ok, {_, simple_built_variants}} =
               simple_built
               |> SimpleBuilts.generate_variants(returning: true)

      list =
        simple_built_variants
        |> Enum.take(4)
        |> Enum.with_index(fn %{id: id}, index ->
          %{
            "id" => id,
            "product_code" => "a",
            "variant_code" => "x-#{index}"
          }
        end)

      assert {:ok, {4, _}} = Stores.upsert_simple_built_variants(store.id, list)
    end
  end

  setup do
    get_fixtures_dir() |> Pczone.initial_data()
    {:ok, store: Pczone.Stores.get_by_code("shopee")}
  end
end
