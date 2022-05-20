defmodule Xeon.MotherboardsTest do
  use Xeon.DataCase
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Motherboards, Motherboard}

  describe "motherboards" do
    test "parse data for upsert" do
      [params | _] = Xeon.Fixtures.read_fixture("motherboards.yml")
      chipsets_map = Xeon.Chipsets.get_map_by_shortname()

      assert %{chipset_id: _} =
               Motherboards.parse_entity_for_upsert(params, chipsets_map: chipsets_map)
    end

    test "upsert" do
      entities = Xeon.Fixtures.read_fixture("motherboards.yml")

      assert {2,
              [
                %Xeon.Motherboard{
                  chipset_id: _,
                  id: _,
                  m2_slots: [
                    %Xeon.M2Slot{
                      processor_index: 1,
                      quantity: 1,
                      supported_types: ["NVMe"],
                      type: "NVMe"
                    }
                  ],
                  m2_slots_count: nil,
                  max_memory_capacity: 64,
                  memory_slots: [
                    %Xeon.MemorySlot{
                      max_capacity: nil,
                      processor_index: 1,
                      quantity: 4,
                      supported_types: ["DIMM DDR4-2133"],
                      type: "DIMM DDR4-2133"
                    }
                  ],
                  memory_slots_count: nil,
                  name: "Dell OptiPlex 7040 SFF",
                  note: nil,
                  pci_slots: [
                    %Xeon.PciSlot{
                      processor_index: 1,
                      quantity: 0,
                      supported_types: nil,
                      type: nil
                    }
                  ],
                  pci_slots_count: nil,
                  processor_slots: [
                    %Xeon.ProcessorSlot{heatsink_type: nil, quantity: 1, socket: nil}
                  ],
                  processor_slots_count: nil,
                  sata_slots: [
                    %Xeon.SataSlot{
                      processor_index: 1,
                      quantity: 1,
                      supported_types: ["Sata 3.0"],
                      type: "Sata 3.0"
                    }
                  ],
                  sata_slots_count: nil
                },
                %Xeon.Motherboard{
                  chipset_id: _,
                  id: _,
                  m2_slots: [
                    %Xeon.M2Slot{
                      processor_index: 1,
                      quantity: 1,
                      supported_types: ["NVMe"],
                      type: "NVMe"
                    }
                  ],
                  m2_slots_count: nil,
                  max_memory_capacity: 32,
                  memory_slots: [
                    %Xeon.MemorySlot{
                      max_capacity: nil,
                      processor_index: 1,
                      quantity: 2,
                      supported_types: ["SODIMM DDR4-2133"],
                      type: "SODIMM DDR4-2133"
                    }
                  ],
                  memory_slots_count: nil,
                  name: "HP EliteDesk 800 G2 Mini",
                  note: nil,
                  pci_slots: [],
                  pci_slots_count: nil,
                  processor_slots: [
                    %Xeon.ProcessorSlot{heatsink_type: nil, quantity: 1, socket: nil}
                  ],
                  processor_slots_count: nil,
                  sata_slots: [
                    %Xeon.SataSlot{
                      processor_index: 1,
                      quantity: 1,
                      supported_types: ["Sata 3.0"],
                      type: "Sata 3.0"
                    }
                  ],
                  sata_slots_count: nil
                }
              ]} = Motherboards.upsert(entities, returning: true)
    end

    test "success" do
      assert {154, _} = Motherboards.import_barebone_motherboards()
    end

    test "add processor" do
      Motherboards.import_barebone_motherboards()
      Xeon.Processors.import_processors()
      motherboard = Repo.one(from Xeon.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Xeon.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end

    test "remove processor" do
      Motherboards.import_barebone_motherboards()
      Xeon.Processors.import_processors()
      motherboard = Repo.one(from Xeon.Motherboard, limit: 1)
      %{id: processor_id} = Repo.one(from Xeon.Processor, limit: 1)
      Motherboards.add_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: [%{id: ^processor_id}]} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)

      Motherboards.remove_processor(%{motherboard_id: motherboard.id, processor_id: processor_id})

      assert %{processors: []} =
               Repo.get(from(Motherboard, preload: [:processors]), motherboard.id)
    end
  end

  setup do
    "chipsets.yml"
    |> Xeon.Fixtures.read_fixture()
    |> Xeon.Chipsets.upsert()

    :ok
  end
end
