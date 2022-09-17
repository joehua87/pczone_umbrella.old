defmodule Pczone.CoolersTest do
  use Pczone.DataCase
  alias Pczone.Coolers

  describe "coolers" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("coolers.yml")

      assert %{
               brand_id: _,
               name: "Cooler Master T400i",
               supported_types: ["LGA2066"]
             } = Coolers.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("coolers.yml")

      assert {:ok,
              {1,
               [
                 %Pczone.Cooler{
                   brand_id: _,
                   id: _,
                   name: "Cooler Master T400i",
                   supported_types: ["LGA2066"]
                 }
                 | _
               ]}} = Coolers.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
