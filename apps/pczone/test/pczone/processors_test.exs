defmodule Pczone.ProcessorsTest do
  use Pczone.DataCase
  alias Pczone.{Processors, Processor}

  describe "processors" do
    test "parse data for upsert" do
      [params | _] = Pczone.Fixtures.read_fixture("processors.yml")

      assert %{
               code: "i3-6100T",
               code_name: "Skylake",
               collection_name: "6th Generation Intel® Core™ i3 Processors",
               cores: 2,
               launch_date: "2015-Q3",
               memory_types: ["DDR4-1866/2133", "DDR3L-1333/1600"],
               name: "Intel® Core™ i3-6100T Processor",
               status: "Discontinued",
               sub: "3M Cache, 3.20 GHz",
               url:
                 "https://ark.intel.com/content/www/us/en/ark/products/90734/intel-core-i36100t-processor-3m-cache-3-20-ghz.html",
               vertical_segment: "Desktop"
             } = Processors.parse_entity_for_upsert(params)
    end

    test "upsert" do
      entities = Pczone.Fixtures.read_fixture("processors.yml")
      assert {:ok, {15, [%Processor{} | _]}} = Processors.upsert(entities, returning: true)
    end

    @tag :skip
    test "import processor chipsets" do
      assert {:ok, {_, _}} = Pczone.Processors.import_processors()
      assert {:ok, {_, _}} = Pczone.Chipsets.import_chipsets()
      assert {:ok, {1709, nil}} = Pczone.Processors.import_chipset_processors()
    end
  end
end
