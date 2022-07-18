defmodule Pczone.SimpleBuiltsTest do
  use Pczone.DataCase
  import Pczone.Fixtures
  alias Pczone.SimpleBuilts

  describe "simple builts" do
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
          option_values: ["i5-6500T", "Ko RAM + Ko SSD"],
          position: 0,
          processor_amount: 1_700_000,
          processor_price: 1_700_000,
          processor_quantity: 1,
          total: 3_500_000,
          name: "i5-6500T,Ko RAM + Ko SSD"
        }
        | _
      ] =
        simple_built_variants =
        SimpleBuilts.generate_variants(simple_built)
        |> Enum.sort(&(&1.position < &2.position))

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
                   option_values: ["i5-6500T", "Ko RAM + Ko SSD"],
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

    test "generate content" do
      [simple_built | _] = simple_builts_fixture()

      assert {:ok, {_, _}} =
               simple_built
               |> SimpleBuilts.generate_variants()
               |> SimpleBuilts.upsert_variants()

      template = """
      {{name}}
      {{#variants}}
      * {{option_values}}: {{total}}
      {{/variants}}
      """

      assert """
             Hp Elitedesk 800 G2 Mini
             * i5-6500T, Ko RAM + Ko SSD: 3.500.000
             * i5-6500T, Ko RAM + 256GB NVMe 95%: 4.250.000
             * i5-6500T, Ko RAM + 256GB NVMe: 4.300.000
             * i5-6500T, Ko RAM + 512GB NVMe: 4.800.000
             * i5-6500T, 8GB + Ko SSD: 4.020.000
             * i5-6500T, 8GB + 256GB NVMe 95%: 4.770.000
             * i5-6500T, 8GB + 256GB NVMe: 4.820.000
             * i5-6500T, 8GB + 512GB NVMe: 5.320.000
             * i5-6500T, 2 x 8GB + Ko SSD: 4.540.000
             * i5-6500T, 2 x 8GB + 256GB NVMe 95%: 5.290.000
             * i5-6500T, 2 x 8GB + 256GB NVMe: 5.340.000
             * i5-6500T, 2 x 8GB + 512GB NVMe: 5.840.000
             * i5-6600T, Ko RAM + Ko SSD: 3.600.000
             * i5-6600T, Ko RAM + 256GB NVMe 95%: 4.350.000
             * i5-6600T, Ko RAM + 256GB NVMe: 4.400.000
             * i5-6600T, Ko RAM + 512GB NVMe: 4.900.000
             * i5-6600T, 8GB + Ko SSD: 4.120.000
             * i5-6600T, 8GB + 256GB NVMe 95%: 4.870.000
             * i5-6600T, 8GB + 256GB NVMe: 4.920.000
             * i5-6600T, 8GB + 512GB NVMe: 5.420.000
             * i5-6600T, 2 x 8GB + Ko SSD: 4.640.000
             * i5-6600T, 2 x 8GB + 256GB NVMe 95%: 5.390.000
             * i5-6600T, 2 x 8GB + 256GB NVMe: 5.440.000
             * i5-6600T, 2 x 8GB + 512GB NVMe: 5.940.000
             * i7-6700T, Ko RAM + Ko SSD: 4.500.000
             * i7-6700T, Ko RAM + 256GB NVMe 95%: 5.250.000
             * i7-6700T, Ko RAM + 256GB NVMe: 5.300.000
             * i7-6700T, Ko RAM + 512GB NVMe: 5.800.000
             * i7-6700T, 8GB + Ko SSD: 5.020.000
             * i7-6700T, 8GB + 256GB NVMe 95%: 5.770.000
             * i7-6700T, 8GB + 256GB NVMe: 5.820.000
             * i7-6700T, 8GB + 512GB NVMe: 6.320.000
             * i7-6700T, 2 x 8GB + Ko SSD: 5.540.000
             * i7-6700T, 2 x 8GB + 256GB NVMe 95%: 6.290.000
             * i7-6700T, 2 x 8GB + 256GB NVMe: 6.340.000
             * i7-6700T, 2 x 8GB + 512GB NVMe: 6.840.000
             """ = SimpleBuilts.generate_content(simple_built.id, template)
    end
  end

  setup do
    get_fixtures_dir()
    |> Pczone.initial_data()

    :ok
  end
end
