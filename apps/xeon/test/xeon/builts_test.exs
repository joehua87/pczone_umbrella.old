defmodule Xeon.BuiltsTest do
  use Xeon.DataCase
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Builts, Barebones, Processors, Memories, Products}

  describe "builts" do
    test "create with barebone", %{
      barebone_id: barebone_id,
      barebone_product_id: barebone_product_id,
      processor_id: processor_id,
      processor_product_id: processor_product_id,
      memory_id: memory_id,
      memory_slot_type: memory_slot_type,
      memory_product_id: memory_product_id
    } do
      params = %{
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
        hard_drives: [],
        gpus: []
      }

      assert {
               :ok,
               %Xeon.Built{
                 id: id,
                 slug: "my-built",
                 barebone_price: 2_000_000,
                 total: 4_740_000
               }
             } = Builts.create(params)

      assert %{
               built_memories: [%{price: 520_000, quantity: 2, total: 1_040_000}],
               built_processors: [%{price: 1_700_000, quantity: 1, total: 1_700_000}]
             } =
               Xeon.Repo.get(from(Xeon.Built, preload: [:built_processors, :built_memories]), id)
    end
  end

  setup do
    Xeon.Fixtures.get_fixtures_dir() |> Xeon.initial_data()
    Xeon.Fixtures.read_fixture("products.yml")

    %{id: barebone_id} = Barebones.get_by_code("hp-elitedesk-800-g2-mini-65w")
    %{id: barebone_product_id} = Products.get_by_sku("hp-elitedesk-800-g2-mini-65w/used")
    %{id: processor_id} = Processors.get_by_code("i5-6500")
    %{id: processor_product_id} = Products.get_by_sku("i5-6500/tray")
    %{id: memory_id, type: memory_slot_type} = Memories.get_by_code("8gb-sodimm-ddr4-2133-mixed")
    %{id: memory_product_id} = Products.get_by_sku("8gb-sodimm-ddr4-2133-mixed/used")

    {:ok,
     barebone_id: barebone_id,
     barebone_product_id: barebone_product_id,
     processor_id: processor_id,
     processor_product_id: processor_product_id,
     memory_id: memory_id,
     memory_slot_type: memory_slot_type,
     memory_product_id: memory_product_id}
  end
end
