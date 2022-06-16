defmodule PcZone.HardDrivesTest do
  use PcZone.DataCase
  alias PcZone.HardDrives

  describe "hard drives" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = PcZone.Fixtures.read_fixture("hard_drives.yml")

      assert %{
               brand_id: _,
               capacity: 256,
               name: "256Gb Samsung PM981 NVMe PCIe 3.0 x4",
               type: "nvme pcie 3.0 x4",
               collection: "PM981",
               form_factor: "m2 2280",
               sequential_read: 3000,
               sequential_write: 1300,
               random_read: 130_000,
               random_write: 310_000,
               tbw: 150
             } = HardDrives.parse_entity_for_upsert(params, brands_map: brands_map)
    end

    test "upsert" do
      entities = PcZone.Fixtures.read_fixture("hard_drives.yml")

      assert {12,
              [
                %PcZone.HardDrive{
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
    "brands.yml" |> PcZone.Fixtures.read_fixture() |> PcZone.Brands.upsert()
    brands_map = PcZone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
