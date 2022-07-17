defmodule Pczone.GpusTest do
  use Pczone.DataCase
  alias Pczone.Gpus

  describe "gpus" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("gpus.yml")

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
      entities = Pczone.Fixtures.read_fixture("gpus.yml")

      assert {:ok,
              {5,
               [
                 %Pczone.Gpu{
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
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
