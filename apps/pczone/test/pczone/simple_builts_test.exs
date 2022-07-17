defmodule Pczone.SimpleBuiltsTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  alias Pczone.SimpleBuilts

  describe "simple builds" do
    test "upsert" do
      list = Pczone.Fixtures.read_fixture("simple_builts.yml")
      {:ok, [%Pczone.SimpleBuilt{} | _]} = Pczone.SimpleBuilts.upsert(list)
    end

    test "generate simple built variants" do
      [simple_built | _] = simple_builts_fixture()

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
          option_values: ["i5-6500T", "Không RAM, Không SSD"],
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
          hard_drive_amount: 0,
          hard_drive_price: 0,
          hard_drive_quantity: 0,
          memory_amount: 0,
          memory_price: 0,
          memory_quantity: 0,
          option_values: ["i5-6600T", "Không RAM, Không SSD"],
          processor_amount: 1_800_000,
          processor_price: 1_800_000,
          processor_quantity: 1,
          total: 3_600_000
        }
        | _
      ] =
        simple_built_variants =
        SimpleBuilts.generate_variants(simple_built) |> Enum.sort(&(&1.total < &2.total))

      assert length(simple_built_variants) ==
               length(simple_built.processors) *
                 (length(simple_built.memories) + 1) *
                 (length(simple_built.hard_drives) + 1)
    end

    test "upsert generated simple built variants" do
      [simple_built | _] = simple_builts_fixture()

      assert {:ok,
              {_,
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
                   option_values: ["i5-6500T", "Không RAM, Không SSD"],
                   processor_amount: 1_700_000,
                   processor_price: 1_700_000,
                   processor_quantity: 1,
                   total: 3_500_000
                 }
                 | _
               ]}} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants(returning: true)
    end
  end

  setup do
    get_fixtures_dir()
    |> Pczone.initial_data()

    :ok
  end
end