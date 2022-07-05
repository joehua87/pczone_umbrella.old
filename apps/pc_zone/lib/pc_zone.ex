defmodule PcZone do
  @moduledoc """
  PcZone keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def initial_data(dir) do
    barebones = dir |> Path.join("barebones.yml") |> YamlElixir.read_from_file!()
    brands = dir |> Path.join("brands.yml") |> YamlElixir.read_from_file!()
    chassises = dir |> Path.join("chassises.yml") |> YamlElixir.read_from_file!()
    chipsets = dir |> Path.join("chipsets.yml") |> YamlElixir.read_from_file!()
    gpus = dir |> Path.join("gpus.yml") |> YamlElixir.read_from_file!()
    hard_drives = dir |> Path.join("hard_drives.yml") |> YamlElixir.read_from_file!()
    memories = dir |> Path.join("memories.yml") |> YamlElixir.read_from_file!()
    motherboards = dir |> Path.join("motherboards.yml") |> YamlElixir.read_from_file!()
    processors = dir |> Path.join("processors.yml") |> YamlElixir.read_from_file!()
    psus = dir |> Path.join("psus.yml") |> YamlElixir.read_from_file!()
    heatsinks = dir |> Path.join("heatsinks.yml") |> YamlElixir.read_from_file!()
    products = dir |> Path.join("products.yml") |> YamlElixir.read_from_file!()

    PcZone.Brands.upsert(brands)
    PcZone.Chipsets.upsert(chipsets)
    PcZone.Motherboards.upsert(motherboards)
    PcZone.Processors.upsert(processors)
    PcZone.Memories.upsert(memories)
    PcZone.HardDrives.upsert(hard_drives)
    PcZone.Gpus.upsert(gpus)
    PcZone.Chassises.upsert(chassises)
    PcZone.Psus.upsert(psus)
    PcZone.Heatsinks.upsert(heatsinks)
    PcZone.Barebones.upsert(barebones)
    PcZone.Chipsets.upsert_chipset_processors(chipsets)
    PcZone.Motherboards.upsert_motherboard_processors(motherboards)
    PcZone.Products.upsert(products)
  end
end
