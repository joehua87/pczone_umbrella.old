defmodule Pczone.SampleData do
  import Ecto.Query, only: [from: 2]

  def get_chipsets(output \\ "chipsets.json") do
    fields = [
      :code,
      :code_name,
      :name,
      :launch_date,
      :collection_name,
      :vertical_segment,
      :status
      # :taxonomies
    ]

    entities = Pczone.Repo.all(from c in Pczone.Chipset, select: map(c, ^fields))
    File.write(output, Jason.encode!(entities))
  end

  def get_motherboards(output \\ "motherboards.json") do
    fields = [
      :name,
      :max_memory_capacity,
      :processor_slots,
      :memory_slots,
      :sata_slots,
      :m2_slots,
      :pci_slots,
      :chipset_id
      # :taxonomies
    ]

    entities =
      Pczone.Repo.all(
        from m in Pczone.Motherboard,
          preload: [:chipset],
          where: m.name in ["HP EliteDesk 800 G2 Mini", "Dell OptiPlex 7040 SFF"],
          select: ^fields
      )
      |> Enum.map(
        &(&1
          |> Map.put(:chipset, &1.chipset.code)
          |> Map.take(fields ++ [:chipset])
          |> Map.drop([:chipset_id]))
      )

    File.write(output, Jason.encode!(entities))
  end

  def get_processors() do
  end
end
