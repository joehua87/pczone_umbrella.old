defmodule Pczone.HardDrivesTest do
  use Pczone.DataCase
  alias Pczone.HardDrives

  describe "hard drives" do
    test "parse data for upsert", %{brands_map: brands_map} do
      [params | _] = Pczone.Fixtures.read_fixture("hard_drives.yml")

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
      entities = Pczone.Fixtures.read_fixture("hard_drives.yml")

      assert {:ok,
              {12,
               [
                 %Pczone.HardDrive{
                   brand_id: _,
                   capacity: 256,
                   collection: "PM981",
                   form_factor: "m2 2280",
                   id: _,
                   name: "256Gb Samsung PM981 NVMe PCIe 3.0 x4",
                   type: "nvme pcie 3.0 x4"
                 }
                 | _
               ]}} = HardDrives.upsert(entities, returning: true)
    end
  end

  setup do
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()
    brands_map = Pczone.Brands.get_map_by_slug()
    {:ok, brands_map: brands_map}
  end
end
