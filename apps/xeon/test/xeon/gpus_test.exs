defmodule Xeon.GpusTest do
  use Xeon.DataCase
  alias Xeon.Gpus

  describe "gpus" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Xeon.Fixtures.read_fixture("gpus.yml")

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
      entities = Xeon.Fixtures.read_fixture("gpus.yml")

      assert {5,
              [
                %Xeon.Gpu{
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
              ]} = Gpus.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    brands_map = Xeon.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
