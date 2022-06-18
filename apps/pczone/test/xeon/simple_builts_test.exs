defmodule PcZone.SimpleBuiltsTest do
  use PcZone.DataCase
  import PcZone.Fixtures
  import Ecto.Query, only: [from: 2]
  alias PcZone.{Repo, SimpleBuilts}

  describe "simple builds" do
    test "upsert" do
      assert {:ok,
              [
                %PcZone.SimpleBuilt{
                  code: "hp-elitedesk-800-g2-mini",
                  hard_drives: [
                    %PcZone.SimpleBuiltHardDrive{},
                    %PcZone.SimpleBuiltHardDrive{},
                    %PcZone.SimpleBuiltHardDrive{}
                  ],
                  memories: [
                    %PcZone.SimpleBuiltMemory{quantity: 1},
                    %PcZone.SimpleBuiltMemory{quantity: 2}
                  ],
                  name: "Hp Elitedesk 800 G2 Mini",
                  processors: [
                    %PcZone.SimpleBuiltProcessor{},
                    %PcZone.SimpleBuiltProcessor{},
                    %PcZone.SimpleBuiltProcessor{}
                  ]
                }
              ]} = create_simple_built()
    end

    @tag :wip
    test "generate simple built products" do
      {:ok, [simple_built]} = create_simple_built()

      [simple_built_variant | _] =
        simple_built_variants = SimpleBuilts.generate_variants(simple_built)

      assert length(simple_built_variants) ==
               length(simple_built.processors) *
                 length(simple_built.memories) *
                 length(simple_built.hard_drives)

      assert %{
               barebone_price: 1_800_000,
               gpu_amount: 0,
               gpu_price: 0,
               gpu_quantity: 0,
               hard_drive_amount: 750_000,
               hard_drive_price: 750_000,
               hard_drive_quantity: 1,
               memory_amount: 520_000,
               memory_price: 520_000,
               memory_quantity: 1,
               option_value_1: "i5-6500T",
               option_value_2: "8GB - 256GB NVMe 95%",
               processor_amount: 1_700_000,
               processor_price: 1_700_000,
               processor_quantity: 1,
               total: 4_770_000
             } = simple_built_variant
    end
  end

  setup do
    get_fixtures_dir()
    |> PcZone.initial_data()

    :ok
  end

  def create_simple_built() do
    list = PcZone.Fixtures.read_fixture("simple_builts.yml")
    codes = Enum.map(list, & &1["code"])

    with {:ok, _} <- SimpleBuilts.upsert(list) do
      {:ok,
       Repo.all(
         from b in PcZone.SimpleBuilt,
           where: b.code in ^codes,
           preload: [
             :barebone,
             :barebone_product,
             {:processors, [:processor_product, :gpu_product]},
             {:memories, :memory_product},
             {:hard_drives, :hard_drive_product}
           ],
           limit: 1
       )}
    end
  end
end
