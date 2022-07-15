defmodule PcZone.ChassisesTest do
  use PcZone.DataCase
  alias PcZone.Chassises

  describe "chassises" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = PcZone.Fixtures.read_fixture("chassises.yml")

      assert %{
               brand_id: _,
               form_factor: "sff",
               name: "Dell OptiPlex 7040 SFF",
               hard_drive_slots: [%{form_factor: "3.5", quantity: 1}]
             } = Chassises.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("chassises.yml")

      assert {:ok,
              {5,
               [
                 %PcZone.Chassis{
                   brand_id: _,
                   form_factor: "sff",
                   id: _,
                   name: "Dell OptiPlex 7040 SFF",
                   hard_drive_slots: [%{form_factor: "3.5", quantity: 1}],
                   psu_form_factors: []
                 }
                 | _
               ]}} = Chassises.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    brands_map = PcZone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
