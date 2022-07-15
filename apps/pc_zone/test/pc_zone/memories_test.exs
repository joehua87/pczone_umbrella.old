defmodule PcZone.MemoriesTest do
  use PcZone.DataCase
  alias PcZone.Memories

  describe "memories" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = PcZone.Fixtures.read_fixture("memories.yml")

      assert %{
               brand_id: _,
               capacity: 4,
               description: "Samsung / Hynix / Micro",
               name: "4Gb SODIMM DDR4 2133 Mixed",
               type: "sodimm ddr4-2133"
             } = Memories.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("memories.yml")

      assert {:ok,
              {18,
               [
                 %PcZone.Memory{
                   brand_id: _,
                   capacity: 4,
                   description: "Samsung / Hynix / Micro",
                   id: _,
                   name: "4Gb SODIMM DDR4 2133 Mixed",
                   type: "sodimm ddr4-2133"
                 }
                 | _
               ]}} = Memories.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    brands_map = PcZone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
