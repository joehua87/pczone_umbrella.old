defmodule Pczone.BuiltsTest do
  use Pczone.DataCase
  import Ecto.Query, only: [from: 2]
  import Pczone.Fixtures
  alias Pczone.{Builts, Barebones, Processors, Memories, Products, HardDrives}

  describe "builts" do
    test "create with barebone", %{built_params: built_params} do
      assert {
               :ok,
               %Pczone.Built{id: id, slug: "my-built"}
             } = Builts.create(built_params)

      built_query =
        from Pczone.Built,
          preload: [:built_processors, :built_memories, :built_hard_drives]

      assert %{
               built_memories: [%{quantity: 2}],
               built_processors: [%{quantity: 1}],
               built_hard_drives: [
                 %{quantity: 1, slot_type: "nvme pcie 3.0 x4"},
                 %{quantity: 1, slot_type: "sata 3"}
               ]
             } = Pczone.Repo.get(built_query, id)
    end

    test "delete built", %{built_params: built_params} do
      assert {:ok, %Pczone.Built{id: id}} = Builts.create(built_params)
      assert {:ok, _} = Builts.delete(id)
    end

    test "calculate total", %{built_params: built_params} do
      assert {
               :ok,
               %Pczone.Built{id: id, slug: "my-built"}
             } = Builts.create(built_params)

      assert %{
               items: [
                 %{
                   component_type: :barebone,
                   price: 2_000_000,
                   product_id: _,
                   quantity: 1,
                   stock: 10,
                   title: "HP EliteDesk 800 G2 Mini 65w (Used)",
                   total: 2_000_000
                 },
                 %{
                   component_type: :processor,
                   price: 1_700_000,
                   product_id: _,
                   quantity: 1,
                   stock: 10,
                   title: "Intel® Core™ i5-6500 Processor (Tray)",
                   total: 1_700_000
                 },
                 %{
                   component_type: :memory,
                   price: 520_000,
                   product_id: _,
                   quantity: 2,
                   stock: 5,
                   title: "8Gb SODIMM DDR4 2133 Mixed (Used)",
                   total: 1_040_000
                 },
                 %{
                   component_type: :hard_drive,
                   price: 800_000,
                   product_id: _,
                   quantity: 1,
                   stock: 10,
                   title: "256Gb Samsung PM981 NVMe PCIe 3.0 x4 (100%)",
                   total: 800_000
                 },
                 %{
                   component_type: :hard_drive,
                   price: 2_000_000,
                   product_id: _,
                   quantity: 1,
                   stock: 10,
                   title: "1Tb Samsung 860 Evo Sata 3 (100%)",
                   total: 2_000_000
                 }
               ],
               stock: 5,
               total: 7_540_000
             } = Builts.calculate_built_price(id)
    end

    test "calculate built price" do
      [built_template | _] = built_templates_fixture()

      assert {:ok, %{builts_map: builts_map}} =
               Pczone.BuiltTemplates.generate_builts(built_template)

      sample_built =
        builts_map
        |> Map.values()
        |> Enum.find(
          &(&1.built_template_id == built_template.id && &1.name == "i5-6500T,8GB + Ko SSD")
        )

      assert %{
               items: [
                 %{
                   component_type: :barebone,
                   price: 1_800_000,
                   product_id: _,
                   quantity: 1,
                   title: "HP EliteDesk 800 G2 Mini (Used)",
                   total: 1_800_000
                 },
                 %{
                   component_type: :processor,
                   price: 1_700_000,
                   product_id: _,
                   quantity: 1,
                   title: "Intel® Core™ i5-6500T Processor (Tray)",
                   total: 1_700_000
                 },
                 %{
                   component_type: :memory,
                   price: 520_000,
                   product_id: _,
                   quantity: 1,
                   title: "8Gb SODIMM DDR4 2133 Mixed (Used)",
                   total: 520_000
                 }
               ],
               total: 4_020_000
             } = Pczone.Builts.calculate_built_price(sample_built.id)
    end

    test "calculate builts price" do
      [built_template | _] = built_templates_fixture()

      assert {:ok, %{builts_map: builts_map}} =
               Pczone.BuiltTemplates.generate_builts(built_template)

      built_ids = Map.values(builts_map) |> Enum.map(& &1.id)
      assert %{} = result = Pczone.Builts.calculate_builts_price(built_ids)
      assert result |> Map.keys() |> length() == 36
    end
  end

  setup do
    Pczone.Fixtures.get_fixtures_dir() |> Pczone.initial_data()
    Pczone.Fixtures.read_fixture("products.xlsx")

    %{id: barebone_id} = Barebones.get_by_code("hp-elitedesk-800-g2-mini-65w")
    %{id: barebone_product_id} = Products.get_by_code("hp-elitedesk-800-g2-mini-65w/used")
    %{id: processor_id} = Processors.get_by_code("i5-6500")
    %{id: processor_product_id} = Products.get_by_code("i5-6500/tray")
    %{id: memory_id, type: memory_slot_type} = Memories.get_by_code("8gb-sodimm-ddr4-2133-mixed")
    %{id: memory_product_id} = Products.get_by_code("8gb-sodimm-ddr4-2133-mixed/used")
    %{id: m2_id, type: m2_slot_type} = HardDrives.get_by_code("256gb-samsung-pm981")
    %{id: m2_product_id} = Products.get_by_code("256gb-samsung-pm981/100%")
    %{id: sata_id, type: sata_slot_type} = HardDrives.get_by_code("1tb-samsung-860-evo")
    %{id: sata_product_id} = Products.get_by_code("1tb-samsung-860-evo/100%")

    built_params = %{
      name: "My built",
      barebone_id: barebone_id,
      barebone_product_id: barebone_product_id,
      processor: %{
        processor_id: processor_id,
        product_id: processor_product_id,
        quantity: 1
      },
      memory: %{
        memory_id: memory_id,
        product_id: memory_product_id,
        slot_type: memory_slot_type,
        processor_index: 1,
        quantity: 2
      },
      hard_drives: [
        %{
          hard_drive_id: m2_id,
          product_id: m2_product_id,
          slot_type: m2_slot_type,
          processor_index: 1,
          quantity: 1
        },
        %{
          hard_drive_id: sata_id,
          product_id: sata_product_id,
          slot_type: sata_slot_type,
          processor_index: 1,
          quantity: 1
        }
      ],
      gpus: []
    }

    {:ok, built_params: built_params}
  end
end
