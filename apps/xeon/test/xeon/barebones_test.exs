defmodule Xeon.BarebonesTest do
  use Xeon.DataCase

  describe "barebones" do
    test "parse data for upsert", %{
      brands_map: brands_map,
      motherboards_map: motherboards_map,
      psus_map: psus_map,
      chassises_map: chassises_map
    } do
      [params | _] = Xeon.Fixtures.read_fixture("barebones.yml")

      assert %{
               brand_id: _,
               chassis_id: _,
               motherboard_id: _,
               name: "HP EliteDesk 800 G2 Mini",
               psu_id: _,
               slug: "hp-elitedesk-800-g2-mini"
             } =
               Xeon.Barebones.parse_entity_for_upsert(params,
                 brands_map: brands_map,
                 motherboards_map: motherboards_map,
                 psus_map: psus_map,
                 chassises_map: chassises_map
               )
    end

    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("barebones.yml")

      assert {3,
              [
                %Xeon.Barebone{
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
              ]} = Xeon.Barebones.upsert(entities, returning: true)
    end
  end

  setup do
    "chipsets.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Chipsets.upsert()
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    "motherboards.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Motherboards.upsert()
    "psus.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Psus.upsert()
    "chassises.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Chassises.upsert()

    {:ok,
     brands_map: Xeon.Brands.get_map_by_slug(),
     motherboards_map: Xeon.Motherboards.get_map_by_slug(),
     psus_map: Xeon.Psus.get_map_by_slug(),
     chassises_map: Xeon.Chassises.get_map_by_slug()}
  end
end
