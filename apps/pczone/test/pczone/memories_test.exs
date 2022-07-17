defmodule Pczone.MemoriesTest do
  use Pczone.DataCase
  alias Pczone.Memories

  describe "memories" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("memories.yml")

      assert %{
               brand_id: _,
               capacity: 4,
               description: "Samsung / Hynix / Micro",
               name: "4Gb SODIMM DDR4 2133 Mixed",
               type: "sodimm ddr4-2133"
             } = Memories.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("memories.yml")

      assert {:ok,
              {18,
               [
                 %Pczone.Memory{
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
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
