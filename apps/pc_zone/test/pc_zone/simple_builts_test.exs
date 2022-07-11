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

    test "generate simple built variants" do
      {:ok, [simple_built]} = create_simple_built()

      [
        %{
          barebone_price: 1_800_000,
          gpu_amount: 0,
          gpu_price: 0,
          gpu_quantity: 0,
          hard_drive_amount: 0,
          hard_drive_price: 0,
          hard_drive_quantity: 0,
          memory_amount: 0,
          memory_price: 0,
          memory_quantity: 0,
          option_values: ["i5-6500T", "Không RAM + Không ổ cứng"],
          processor_amount: 1_700_000,
          processor_price: 1_700_000,
          processor_quantity: 1,
          total: 3_500_000
        },
        %{
          barebone_price: 1_800_000,
          gpu_amount: 0,
          gpu_price: 0,
          gpu_quantity: 0,
          hard_drive_amount: 750_000,
          hard_drive_price: 750_000,
          hard_drive_quantity: 1,
          memory_amount: 0,
          memory_price: 0,
          memory_quantity: 0,
          option_values: ["i5-6500T", "Không RAM + 256GB NVMe 95%"],
          processor_amount: 1_700_000,
          processor_price: 1_700_000,
          processor_quantity: 1,
          total: 4_250_000
        }
        | _
      ] = simple_built_variants = SimpleBuilts.generate_variants(simple_built)

      assert length(simple_built_variants) ==
               length(simple_built.processors) *
                 (length(simple_built.memories) + 1) *
                 (length(simple_built.hard_drives) + 1)
    end

    test "upsert generated simple built variants" do
      {:ok, [simple_built]} = create_simple_built()

      assert {_,
              [
                %{
                  barebone_price: 1_800_000,
                  gpu_amount: 0,
                  gpu_price: 0,
                  gpu_quantity: 0,
                  hard_drive_amount: 0,
                  hard_drive_price: 0,
                  hard_drive_quantity: 0,
                  memory_amount: 0,
                  memory_price: 0,
                  memory_quantity: 0,
                  option_values: ["i5-6500T", "Không RAM + Không ổ cứng"],
                  processor_amount: 1_700_000,
                  processor_price: 1_700_000,
                  processor_quantity: 1,
                  total: 3_500_000
                }
                | _
              ]} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants(returning: true)
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
