defmodule Xeon.BarebonesTest do
  use Xeon.DataCase
  alias Xeon.Barebones

  describe "chipsets" do
    @tag :wip
    test "parse hardware-corner" do
      params = Xeon.Fixtures.read_fixture("barebone.json")
      Xeon.Chipsets.import_chipsets()
      chipsets_map = Xeon.Chipsets.get_map_by_shortname()

      Barebones.parse(:hardware_corner, params, chipsets_map: chipsets_map)
      |> Barebones.create()
    end
  end
end
