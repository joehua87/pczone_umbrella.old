defmodule Xeon do
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Xeon keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def initial_data() do
    Xeon.Chipsets.import_chipsets()
    Xeon.Processors.import_processors()
    Xeon.Processors.import_processor_chipsets()
    Xeon.Motherboards.import_barebone_motherboards()
  end

  def import_brands() do
    brands = [
      "Acer",
      "ADATA",
      "AMD",
      "Asus",
      "Dell",
      "Gigabyte",
      "HP",
      "Intel",
      "Kingmax",
      "Kingston",
      "Lenovo",
      "Micron",
      "MSI",
      "Nvidia",
      "Samsung"
    ]

    entities = brands |> Enum.map(&%{name: &1})
    Xeon.Repo.insert_all(Xeon.Brand, entities)
  end

  def import_memories() do
    memory_types =
      Xeon.Repo.all(from m in Xeon.Motherboard, select: m.memory_types)
      |> List.flatten()
      |> Enum.uniq()

    capacity_list = [4, 8, 16, 32]

    brands_map = Xeon.Repo.all(from b in Xeon.Brand, select: {b.name, b.id}) |> Enum.into(%{})

    brands = [
      "ADATA",
      "Kingmax",
      "Kingston",
      "Micron",
      "Samsung"
    ]

    entities =
      memory_types
      |> Enum.flat_map(fn type ->
        Enum.map(capacity_list, fn capacity ->
          %{
            type: type,
            capacity: capacity
          }
        end)
      end)
      |> Enum.flat_map(fn %{type: type, capacity: capacity} ->
        Enum.map(brands, fn brand ->
          brand_id = brands_map[brand]

          %{
            name: "#{capacity} Gb #{brand} #{type}",
            type: type,
            capacity: capacity,
            brand_id: brand_id
          }
        end)
      end)

    Xeon.Repo.insert_all(Xeon.Memory, entities)
  end

  def generate_products() do
    generate_motherboard_products()
    generate_processor_products()
    generate_memory_products()
  end

  def generate_motherboard_products() do
    motherboards = Xeon.Repo.all(Xeon.Motherboard)

    entities =
      Enum.flat_map(motherboards, fn %{id: motherboard_id, name: name} ->
        [
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "new",
            list_price: 1_000_000,
            sale_price: 1_000_000,
            percentage_off: 0,
            motherboard_id: motherboard_id
          },
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "used",
            list_price: 800_000,
            sale_price: 800_000,
            percentage_off: 0,
            motherboard_id: motherboard_id
          }
        ]
      end)

    Xeon.Repo.insert_all(Xeon.Product, entities)
  end

  def generate_processor_products() do
    processors = Xeon.Repo.all(Xeon.Processor)

    entities =
      Enum.flat_map(processors, fn %{id: processor_id, name: name} ->
        [
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "new",
            list_price: 1_000_000,
            sale_price: 1_000_000,
            percentage_off: 0,
            processor_id: processor_id
          },
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "used",
            list_price: 800_000,
            sale_price: 800_000,
            percentage_off: 0,
            processor_id: processor_id
          }
        ]
      end)

    Xeon.Repo.insert_all(Xeon.Product, entities)
  end

  def generate_memory_products() do
    memories = Xeon.Repo.all(Xeon.Memory)

    entities =
      Enum.flat_map(memories, fn %{id: memory_id, name: name} ->
        [
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "new",
            list_price: 1_000_000,
            sale_price: 1_000_000,
            percentage_off: 0,
            memory_id: memory_id
          },
          %{
            slug: Slug.slugify(name),
            title: name,
            condition: "used",
            list_price: 800_000,
            sale_price: 800_000,
            percentage_off: 0,
            memory_id: memory_id
          }
        ]
      end)

    Xeon.Repo.insert_all(Xeon.Product, entities)
  end
end
