defmodule Pczone.HeatsinksTest do
  use Pczone.DataCase
  alias Pczone.Heatsinks

  describe "heatsinks" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("heatsinks.yml")

      assert %{
               brand_id: _,
               name: "Cooler Master T400i",
               supported_types: ["LGA2066"]
             } = Heatsinks.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("heatsinks.yml")

      assert {:ok,
              {1,
               [
                 %Pczone.Heatsink{
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
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
