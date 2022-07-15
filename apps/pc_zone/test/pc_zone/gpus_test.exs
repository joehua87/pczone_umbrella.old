defmodule PcZone.GpusTest do
  use PcZone.DataCase
  alias PcZone.Gpus

  describe "gpus" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = PcZone.Fixtures.read_fixture("gpus.yml")

      assert %{
               brand_id: _,
               form_factors: ["low", "high"],
               memory_capacity: 1024,
               memory_type: "DDR3",
               name: "Nvidia Quandro K600",
               type: "pcie 2.0 x16"
             } = Gpus.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("gpus.yml")

      assert {:ok,
              {5,
               [
                 %PcZone.Gpu{
                   brand_id: _,
                   form_factors: ["low", "high"],
                   id: _,
                   memory_capacity: 1024,
                   memory_type: "DDR3",
                   name: "Nvidia Quandro K600",
                   tdp: nil,
                   type: "pcie 2.0 x16"
                 }
                 | _
               ]}} = Gpus.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    brands_map = PcZone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
