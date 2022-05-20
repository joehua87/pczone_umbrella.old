defmodule Xeon.PsusTest do
  use Xeon.DataCase
  alias Xeon.Psus

  describe "psus" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Xeon.Fixtures.read_fixture("psus.yml")

      assert %{
               brand_id: _,
               form_factor: "sff",
               name: "Dell OptiPlex 7040 SFF"
             } = Psus.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("psus.yml")

      assert {5,
              [
                %Xeon.Psu{
                  brand_id: _,
                  form_factor: "sff",
                  id: _,
                  name: "Dell OptiPlex 7040 SFF",
                  wattage: 180
                }
                | _
              ]} = Psus.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    brands_map = Xeon.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
