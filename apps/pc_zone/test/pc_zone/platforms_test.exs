defmodule PcZone.PlatformsTest do
  use PcZone.DataCase
  import PcZone.Fixtures
  alias PcZone.{SimpleBuilts, Platforms}

  describe "platforms" do
    test "read simple built variants from xlsx" do
      path = get_fixtures_dir() |> Path.join("shopee-simple-built-variants.xlsx")

      assert [
               %{
                 "id" => 829,
                 "option_values" => "i5-6500T, Không RAM + Không ổ cứng",
                 "price" => 3_500_000,
                 "product_code" => "aaa",
                 "product_name" => "Hp Elitedesk 800 G2 Mini",
                 "stock" => 99,
                 "variant_code" => "x1"
               },
               %{
                 "id" => 830,
                 "option_values" => "i5-6500T, Không RAM + 256GB NVMe 95%",
                 "price" => 4_250_000,
                 "product_code" => "aaa",
                 "product_name" => "Hp Elitedesk 800 G2 Mini",
                 "stock" => 99,
                 "variant_code" => "x2"
               }
               | _
             ] = Platforms.read_platform_simple_built_variants(path)
    end

    test "upsert simple built variants", %{platform: platform} do
      [simple_built | _] = simple_builts_fixture()

      assert {_, simple_built_variants} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants(returning: true)

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

      assert {4, _} = Platforms.upsert_simple_built_variants(platform.id, list)
    end
  end

  setup do
    get_fixtures_dir() |> PcZone.initial_data()
    {:ok, platform} = PcZone.Platforms.create(%{code: "shopee", name: "Shopee", rate: 1.05})
    {:ok, platform: platform}
  end
end
