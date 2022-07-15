defmodule PcZone.HeatsinksTest do
  use PcZone.DataCase
  alias PcZone.Heatsinks

  describe "heatsinks" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = PcZone.Fixtures.read_fixture("heatsinks.yml")

      assert %{
               brand_id: _,
               name: "Cooler Master T400i",
               supported_types: ["LGA2066"]
             } = Heatsinks.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("heatsinks.yml")

      assert {:ok,
              {1,
               [
                 %PcZone.Heatsink{
                   brand_id: _,
                   id: _,
                   name: "Cooler Master T400i",
                   supported_types: ["LGA2066"]
                 }
                 | _
               ]}} = Heatsinks.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    brands_map = PcZone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
