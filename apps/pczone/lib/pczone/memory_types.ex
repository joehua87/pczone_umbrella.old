defmodule Pczone.MemoryTypes do
  @map %{
         "DIMM DDR3-1333" => ["DIMM DDR3-1333"],
         "DIMM DDR3-1333/1600" => ["DIMM DDR3-1333", "DIMM DDR3-1600"],
         "DIMM DDR3-1600" => ["DIMM DDR3-1600"],
         "SODIMM DDR3-1600" => ["SODIMM DDR3-1600"],
         "DIMM DDR3L-1600" => ["DIMM DDR3L-1600"],
         "SODIMM DDR3L-1600" => ["SODIMM DDR3L-1600"],
         "DIMM DDR4-2133/2400" => ["DIMM DDR4-2133", "DIMM DDR4-2400"],
         "SODIMM DDR4-2133/2400" => ["SODIMM DDR4-2133", "SODIMM DDR4-2400"],
         "DIMM DDR4-2400/2666" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
         "SODIMM DDR4-2400/2666" => ["SODIMM DDR4-2400", "SODIMM DDR4-2666"],
         "DIMM DDR4-2666" => ["DIMM DDR4-2666"],
         "SODIMM DDR4-2666" => ["SODIMM DDR4-2666"],
         "DIMM DDR4-2666/2933" => ["DIMM DDR4-2666", "DIMM DDR4-2933"],
         "SODIMM DDR4-2666/2933" => ["SODIMM DDR4-2666", "SODIMM DDR4-2933"],
         "DIMM DDR4-2666/2933/3200" => ["DIMM DDR4-2666", "DIMM DDR4-2933", "DIMM DDR4-3200"],
         "DIMM DDR4-2133" => ["DIMM DDR4-2133"],
         "SODIMM DDR4-2133" => ["SODIMM DDR4-2133"],
         "SODIMM-2133/2400" => ["SODIMM-2133", "SODIMM-2400"],
         "DIMM DDR3-1060/1333" => ["DIMM DDR3-1060", "DIMM DDR3-1333"],
         "DIMM DDR3-1333/1866" => ["DIMM DDR3-1333", "DIMM DDR3-1866"],
         "DIMM DDR4-2400/2667" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
         "DIMM DDR4-2666/3000" => ["DIMM DDR4-2666", "DIMM DDR4-3000"],
         "DIMM DDR4-2933/3400" => ["DIMM DDR4-2933", "DIMM DDR4-3400"],
         "DIMM DDR4-3200/3400" => ["DIMM DDR4-3200", "DIMM DDR4-3400"],
         "DIMM DDR4-4400" => ["DIMM DDR4-4400"],
         "DIMM DDR3-2133" => ["DIMM DDR3-2133"],
         "DIMM DDR4-2133/2667" => ["DIMM DDR4-2133", "DIMM DDR4-2667"],
         "DIMM DDR4-2666/3200" => ["DIMM DDR4-2666", "DIMM DDR4-3200"],
         "SO-DIMM DDR3-1333" => ["SODIMM DDR3-1333"],
         "DIMM DDR4-2400" => ["DIMM DDR4-2400"],
         "DIMM DDR3-2133/2400" => ["DIMM DDR3-2133", "DIMM DDR3-2400"],
         "SODIMM DDR4-2400" => ["SODIMM DDR4-2400"],
         "SODIMM DDR4-2933" => ["SODIMM DDR4-2933"],
         "DIMM DDR4-2933" => ["DIMM DDR4-2933"],
         "SODIMM DDR4-3200" => ["SODIMM DDR4-3200"],
         "DIMM DDR4-3200" => ["DIMM DDR4-3200"],
         "SDIMM DDR3-1600" => ["SODIMM DDR3-1600"]
       }
       |> Enum.map(fn {k, v} ->
         {k, {List.last(v), v}}
       end)
       |> Enum.into(%{})

  def get(:hardware_corner, type) do
    @map[type]
  end
end
