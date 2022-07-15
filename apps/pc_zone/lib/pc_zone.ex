defmodule PcZone do
  @moduledoc """
  PcZone keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def initial_data(dir) when is_bitstring(dir) do
    dir
    |> Path.join("*")
    |> Path.wildcard()
    |> initial_data()
  end

  def initial_data(files) when is_list(files) do
    barebones = read_from_files!(files, ~r/barebones.*?\.ya?ml/)
    brands = read_from_files!(files, ~r/brands.*?\.ya?ml/)
    chassises = read_from_files!(files, ~r/chassises.*?\.ya?ml/)
    chipsets = read_from_files!(files, ~r/chipsets.*?\.ya?ml/)
    gpus = read_from_files!(files, ~r/gpus.*?\.ya?ml/)
    hard_drives = read_from_files!(files, ~r/hard_drives.*?\.ya?ml/)
    memories = read_from_files!(files, ~r/memories.*?\.ya?ml/)
    motherboards = read_from_files!(files, ~r/motherboards.*?\.ya?ml/)
    processors = read_from_files!(files, ~r/processors.*?\.ya?ml/)
    psus = read_from_files!(files, ~r/psus.*?\.ya?ml/)
    heatsinks = read_from_files!(files, ~r/heatsinks.*?\.ya?ml/)
    products = read_from_files!(files, ~r/products.*?\.ya?ml/)

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

  def read_from_files!(files, name_pattern) do
    files
    |> Enum.filter(&(&1 |> Path.basename() |> String.match?(name_pattern)))
    |> Enum.map(&YamlElixir.read_all_from_file!/1)
    |> List.flatten()
  end
end
