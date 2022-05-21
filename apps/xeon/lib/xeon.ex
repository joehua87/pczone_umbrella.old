defmodule Xeon do
  @moduledoc """
  Xeon keeps the contexts that define your domain
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
    products = dir |> Path.join("products.yml") |> YamlElixir.read_from_file!()

    Xeon.Brands.upsert(brands)
    Xeon.Chipsets.upsert(chipsets)
    Xeon.Motherboards.upsert(motherboards)
    Xeon.Processors.upsert(processors)
    Xeon.Memories.upsert(memories)
    Xeon.HardDrives.upsert(hard_drives)
    Xeon.Gpus.upsert(gpus)
    Xeon.Chassises.upsert(chassises)
    Xeon.Psus.upsert(psus)
    Xeon.Barebones.upsert(barebones)
    Xeon.Chipsets.upsert_chipset_processors(chipsets)
    Xeon.Motherboards.upsert_motherboard_processors(motherboards)
    Xeon.Products.upsert(products)
  end
end
