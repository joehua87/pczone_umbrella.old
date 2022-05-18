defmodule Xeon.BarebonesTest do
  use Xeon.DataCase
  alias Xeon.Barebones

  describe "barebones" do
    test "parse from hardware-corner" do
      params = get_sample_barebone()
      Xeon.Chipsets.import_chipsets()
      chipsets_map = Xeon.Chipsets.get_map_by_shortname()

      assert %{
               barebone: %{
                 launch_date: "2015",
                 name: "HP EliteDesk 800 G2 Mini",
                 psu_form_factor: nil,
                 psu_options: [65, 90],
                 raw_data: %{
                   field_values: _,
                   manual_link: "https://ark.intel.com/content" <> _,
                   tables: _
                 },
                 source_website: "www.hardware-corner.net",
                 source_url:
                   "https://www.hardware-corner.net/desktop-models/HP-EliteDesk-800-G2-Mini/",
                 weight: %Decimal{}
               },
               chassis: %{form_factor: "Micro", name: "HP EliteDesk 800 G2 Mini"},
               motherboard: %{
                 _m2_slots: ["M.2 2280 M-key (PCIe x4)", "M.2 2230 (WiFi/BT)"],
                 attributes: [],
                 chipset: "Q170",
                 chipset_id: _,
                 memory_slots: [
                   %{quantity: 2, supported_types: ["SODIMM DDR4-2133"], type: "SODIMM DDR4-2133"}
                 ],
                 memory_slots_count: 2,
                 name: "HP EliteDesk 800 G2 Mini",
                 processor_slots: [%{}],
                 processor_slots_count: 1
               },
               psu: %{name: "HP EliteDesk 800 G2 Mini", wattage: "65/90 W"}
             } = Barebones.parse(:hardware_corner, params, chipsets_map: chipsets_map)
    end

    test "create from hardware-corner" do
      params = get_sample_barebone()
      Xeon.Chipsets.import_chipsets()
      chipsets_map = Xeon.Chipsets.get_map_by_shortname()

      assert {:ok,
              %{
                barebone: %{},
                motherboard: %{},
                chassis: %{},
                psu: %{}
              }} =
               Barebones.parse(:hardware_corner, params, chipsets_map: chipsets_map)
               |> Barebones.create()
    end
  end

  defp get_sample_barebone() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")

    Mongo.find_one(conn, "Product", %{
      "title" => "HP EliteDesk 800 G2 Mini"
    })
  end
end
