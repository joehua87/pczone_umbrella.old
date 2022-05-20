defmodule Xeon.MemoriesTest do
  use Xeon.DataCase
  alias Xeon.Memories

  describe "memories" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Xeon.Fixtures.read_fixture("memories.yml")

      assert %{
               brand_id: _,
               capacity: 4,
               description: "Samsung / Hynix / Micro",
               name: "4Gb SODIMM DDR4 2133",
               type: "SODIMM DDR4-2133"
             } = Memories.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("memories.yml")

      assert {9,
              [
                %Xeon.Memory{
                  brand_id: _,
                  capacity: 4,
                  description: "Samsung / Hynix / Micro",
                  id: _,
                  name: "4Gb SODIMM DDR4 2133",
                  type: "SODIMM DDR4-2133"
                }
                | _
              ]} = Memories.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    brands_map = Xeon.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
