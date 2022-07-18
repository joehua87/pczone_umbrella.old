defmodule Pczone.MotherboardsTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  alias Pczone.{Repo, Motherboards, Motherboard}

  describe "motherboards" do
    test "parse data for upsert", %{brands_map: brands_map, chipsets_map: chipsets_map} do
      [params | _] = Pczone.Fixtures.read_fixture("motherboards.yml")

      assert %{chipset_id: _} =
               Motherboards.parse_entity_for_upsert(params,
                 brands_map: brands_map,
                 chipsets_map: chipsets_map
               )
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("motherboards.yml")

      assert {:ok,
              {4,
               [
                 %Pczone.Motherboard{
                   chipset_id: _,
                   id: _,
                   m2_slots: [
                     %Pczone.M2Slot{
                       processor_index: 1,
                       quantity: 1,
                       type: "nvme pcie 3.0 x4",
                       supported_types: ["nvme pcie 3.0 x4"],
                       form_factors: ["m2 2230", "m2 2280"]
                     }
                   ],
                   m2_slots_count: nil,
                   max_memory_capacity: 64,
                   memory_slots: [
                     %Pczone.MemorySlot{
                       max_capacity: nil,
                       processor_index: 1,
                       quantity: 4,
                       supported_types: ["dimm ddr4-2133" | _],
                       type: "dimm ddr4-2133"
                     }
                   ],
                   memory_slots_count: nil,
                   name: "Dell OptiPlex 7040 SFF",
                   note: nil,
                   pci_slots: [
                     %Pczone.PciSlot{
                       processor_index: 1,
                       quantity: 1,
                       type: "pci express 3.0 x4"
                     },
                     %Pczone.PciSlot{
                       processor_index: 1,
                       quantity: 1,
                       type: "pci express 3.0 x16"
                     }
                   ],
                   pci_slots_count: nil,
                   processor_slots: [
                     %Pczone.ProcessorSlot{heatsink_type: nil, quantity: 1, socket: nil}
                   ],
                   processor_slots_count: nil,
                   sata_slots: [
                     %Pczone.SataSlot{
                       processor_index: 1,
                       quantity: 1,
                       supported_types: ["sata 3"],
                       type: "sata 3"
                     }
                   ],
                   sata_slots_count: nil
                 }
                 | _
               ]}} = Motherboards.upsert(entities, returning: true)
    end

    test "upsert motherboard processors" do
      entities = "motherboards.yml" |> Pczone.Fixtures.read_fixture()
      assert {:ok, {_, _}} = Motherboards.upsert(entities)

      assert {:ok, {_, _}} =
               "processors.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Processors.upsert()

      assert {:ok, {15, _}} =
               Motherboards.upsert_motherboard_processors(entities, returning: true)
    end

    @tag :skip
    test "add processor" do
      Motherboards.import_barebone_motherboards()
      Pczone.Processors.import_processors()
      motherboard = Repo.one(from Pczone.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Pczone.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end

    @tag :skip
    test "remove processor" do
      Motherboards.import_barebone_motherboards()
      Pczone.Processors.import_processors()
      motherboard = Repo.one(from Pczone.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Pczone.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)

      Motherboards.remove_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: []} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end
  end

  setup do
    "chipsets.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Chipsets.upsert()
    "brands.yml" |> Pczone.Fixtures.read_fixture() |> Pczone.Brands.upsert()

    {:ok,
     chipsets_map: Pczone.Chipsets.get_map_by_code(), brands_map: Pczone.Brands.get_map_by_slug()}
  end
end
