defmodule Pczone.PsusTest do
  use Pczone.DataCase
  alias Pczone.Psus

  describe "psus" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("psus.yml")

      assert %{
               brand_id: _,
               form_factor: "sff",
               name: "Dell OptiPlex 7040 SFF"
             } = Psus.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("psus.yml")

      assert {:ok,
              {5,
               [
                 %Pczone.Psu{
                   brand_id: _,
                   form_factor: "sff",
                   id: _,
                   name: "Dell OptiPlex 7040 SFF",
                   wattage: 180
                 }
                 | _
               ]}} = Psus.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
