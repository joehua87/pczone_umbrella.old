defmodule Xeon.HardDrivesTest do
  use Xeon.DataCase
  alias Xeon.HardDrives

  describe "hard drives" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Xeon.Fixtures.read_fixture("hard_drives.yml")

      assert %{
               brand_id: _,
               capacity: 256,
               name: "256Gb Samsung PM981 NVMe PCIe 3.0 x4",
               type: "nvme pcie 3.0 x4",
               collection: "PM981",
               form_factor: "m2 2280"
             } = HardDrives.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    @tag :wip
    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("hard_drives.yml")

      assert {9,
              [
                %Xeon.HardDrive{
                  brand_id: _,
                  capacity: 256,
                  collection: "PM981",
                  form_factor: "m2 2280",
                  id: _,
                  name: "256Gb Samsung PM981 NVMe PCIe 3.0 x4",
                  type: "nvme pcie 3.0 x4"
                }
                | _
              ]} = HardDrives.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Xeon.Fixtures.read_fixture() |> Xeon.Brands.upsert()
    brands_map = Xeon.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
