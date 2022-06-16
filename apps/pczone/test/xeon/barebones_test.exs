defmodule PcZone.BarebonesTest do
  use PcZone.DataCase

  describe "barebones" do
    test "parse data for upsert", %{
      brands_map: brands_map,
      motherboards_map: motherboards_map,
      psus_map: psus_map,
      chassises_map: chassises_map
    } do
      [params | _] = PcZone.Fixtures.read_fixture("barebones.yml")

      assert %{
               brand_id: _,
               chassis_id: _,
               motherboard_id: _,
               name: "HP EliteDesk 800 G2 Mini",
               psu_id: _,
               slug: "hp-elitedesk-800-g2-mini"
             } =
               PcZone.Barebones.parse_entity_for_upsert(params,
                 brands_map: brands_map,
                 motherboards_map: motherboards_map,
                 psus_map: psus_map,
                 chassises_map: chassises_map
               )
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("barebones.yml")

      assert {4,
              [
                %PcZone.Barebone{
                  brand_id: _,
                  chassis_id: _,
                  id: _,
                  launch_date: nil,
                  motherboard_id: _,
                  name: "HP EliteDesk 800 G2 Mini",
                  psu_id: _,
                  slug: "hp-elitedesk-800-g2-mini"
                }
                | _
              ]} = PcZone.Barebones.upsert(entities, returning: true)
    end
  end

  setup do
    "chipsets.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Chipsets.upsert()
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    "motherboards.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Motherboards.upsert()
    "psus.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Psus.upsert()
    "chassises.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Chassises.upsert()

    {:ok,
     brands_map: PcZone.Brands.get_map_by_slug(),
     motherboards_map: PcZone.Motherboards.get_map_by_slug(),
     psus_map: PcZone.Psus.get_map_by_slug(),
     chassises_map: PcZone.Chassises.get_map_by_slug()}
  end
end
