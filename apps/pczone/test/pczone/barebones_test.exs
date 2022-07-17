defmodule Pczone.BarebonesTest do
  use Pczone.DataCase

  describe "barebones" do
    test "parse data for upsert", %{
      brands_map: brands_map,
      motherboards_map: motherboards_map,
      psus_map: psus_map,
      chassises_map: chassises_map
    } do
      [params | _] = Pczone.Fixtures.read_fixture("barebones.yml")

      assert %{
               brand_id: _,
               chassis_id: _,
               motherboard_id: _,
               name: "HP EliteDesk 800 G2 Mini",
               psu_id: _,
               slug: "hp-elitedesk-800-g2-mini"
             } =
               Pczone.Barebones.parse_entity_for_upsert(params,
                 brands_map: brands_map,
                 motherboards_map: motherboards_map,
                 psus_map: psus_map,
                 chassises_map: chassises_map
               )
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("barebones.yml")

      assert {:ok,
              {4,
               [
                 %Pczone.Barebone{
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
               ]}} = Pczone.Barebones.upsert(entities, returning: true)
    end
  end

  setup do
    "chipsets.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Chipsets.upsert()
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    "motherboards.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Motherboards.upsert()
    "psus.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Psus.upsert()
    "chassises.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Chassises.upsert()

    {:ok,
     brands_map: Pczone.Brands.get_map_by_slug(),
     motherboards_map: Pczone.Motherboards.get_map_by_slug(),
     psus_map: Pczone.Psus.get_map_by_slug(),
     chassises_map: Pczone.Chassises.get_map_by_slug()}
  end
end
