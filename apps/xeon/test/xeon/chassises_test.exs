defmodule Xeon.ChassisesTest do
  use Xeon.DataCase
  alias Xeon.Chassises

  describe "chassises" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Xeon.Fixtures.read_fixture("chassises.yml")

      assert %{
               brand_id: _,
               form_factor: "sff",
               name: "Dell OptiPlex 7040 SFF",
               hard_drive_slots: [%{form_factor: "3.5", quantity: 1}]
             } = Chassises.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("chassises.yml")

      assert {5,
              [
                %Xeon.Chassis{
                  brand_id: _,
                  form_factor: "sff",
                  id: _,
                  name: "Dell OptiPlex 7040 SFF",
                  psu_form_factors: []
                }
                | _
              ]} = Chassises.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    brands_map = Xeon.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
