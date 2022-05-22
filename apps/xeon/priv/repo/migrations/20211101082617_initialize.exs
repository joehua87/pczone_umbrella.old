defmodule Xeon.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create_extension(["citext", "unaccent", "ltree"])

    create table(:enum) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :value, :string, null: false
    end

    create index(:enum, [:name])

    create table(:brand) do
      add :slug, :string, null: false
      add :name, :string, null: false
    end

    create unique_index(:brand, [:slug])

    create table(:chipset) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :code_name, :string, null: false
      add :name, :string, null: false
      add :launch_date, :string, null: false
      add :collection_name, :string, null: false
      add :vertical_segment, :string, null: false
      add :status, :string, null: false
      add :attributes, :map, null: false, default: "[]"
    end

    create unique_index(:chipset, [:slug])

    create table(:gpu) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :type, :string, null: false
      add :memory_capacity, :integer, null: false
      add :memory_type, :string, null: false
      add :form_factors, {:array, :string}, null: false
      add :tdp, :integer
      add :brand_id, references(:brand), null: false
    end

    create unique_index(:gpu, [:code])
    create unique_index(:gpu, [:slug])

    create table(:chassis) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :form_factor, :string
      add :hard_drive_slots, :map, default: "[]"
      add :psu_form_factors, {:array, :string}, default: []
      add :brand_id, references(:brand), null: false
    end

    create unique_index(:chassis, [:slug])
    create unique_index(:chassis, [:code])

    create table(:psu) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :wattage, :integer, null: false
      add :form_factor, :string
      add :brand_id, references(:brand), null: false
    end

    create unique_index(:psu, [:slug])
    create unique_index(:psu, [:code])

    create table(:motherboard) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :max_memory_capacity, :integer, null: false
      add :processor_slots, :map, null: false, default: "[]"
      add :memory_slots, :map, null: false, default: "[]"
      add :sata_slots, :map, null: false, default: "[]"
      add :m2_slots, :map, null: false, default: "[]"
      add :pci_slots, :map, null: false, default: "[]"
      add :processor_slots_count, :integer
      add :memory_slots_count, :integer
      add :sata_slots_count, :integer
      add :m2_slots_count, :integer
      add :pci_slots_count, :integer
      add :form_factor, :string
      add :chassis_form_factors, {:array, :string}
      add :chipset_id, references(:chipset), null: false
      add :brand_id, references(:brand), null: false
      add :attributes, :map, null: false, default: "[]"
      add :note, :string
    end

    create unique_index(:motherboard, [:slug])
    create unique_index(:motherboard, [:code])

    create table(:extension_device) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :processor_slots, :map
      add :memory_slots, :map
      add :sata_slots, :map
      add :m2_slots, :map
    end

    create unique_index(:extension_device, [:slug])
    create unique_index(:extension_device, [:code])

    create table(:processor) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :sub, :string, null: false
      add :code_name, :string, null: false
      add :collection_name, :string, null: false
      add :launch_date, :string, null: false
      add :status, :string, null: false
      add :vertical_segment, :string, null: false
      add :socket, :string
      add :case_temperature, :decimal
      add :lithography, :string
      add :base_frequency, :decimal
      add :tdp_up_base_frequency, :decimal
      add :tdp_down_base_frequency, :decimal
      add :max_turbo_frequency, :decimal
      add :tdp, :decimal
      add :tdp_up, :decimal
      add :tdp_down, :decimal
      add :cache_size, :decimal, null: false
      add :cores, :integer, null: false
      add :threads, :integer
      add :processor_graphics, :string
      add :gpu_id, references(:gpu)
      add :url, :string, null: false
      add :memory_types, {:array, :string}, null: false
      add :ecc_memory_supported, :boolean, default: false
      add :meta, :map
      add :attributes, :map, default: "[]"
    end

    # Slug must be unique index
    create unique_index(:processor, [:slug])
    create unique_index(:processor, [:code])
    create unique_index(:processor, [:url])

    create table(:chipset_processor) do
      add :processor_id, references(:processor), null: false
      add :chipset_id, references(:chipset), null: false
    end

    create unique_index(:chipset_processor, [:chipset_id, :processor_id])

    create table(:processor_score) do
      add :processor_id, references(:processor), null: false
      add :test_name, :string, null: false
      add :single, :integer, null: false
      add :multi, :integer, null: false
    end

    create unique_index(:processor_score, [:processor_id, :test_name])

    create table(:barebone) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :motherboard_id, references(:motherboard), null: false
      add :chassis_id, references(:chassis), null: false
      add :psu_id, references(:psu)
      add :brand_id, references(:brand), null: false
      add :processor_id, references(:processor)
      add :weight, :decimal
      add :launch_date, :string
      add :url, :string
      add :raw_data, :map
      add :source_website, :string
      add :source_url, :string
    end

    create unique_index(:barebone, [:slug])

    create table(:memory) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :description, :string
      add :type, :string, null: false
      add :capacity, :integer, null: false
      add :tdp, :integer
      add :brand_id, references(:brand), null: false
    end

    create unique_index(:memory, [:slug])
    create unique_index(:memory, [:type, :capacity, :brand_id])

    create table(:motherboard_processor) do
      add :motherboard_id, references(:motherboard), null: false
      add :processor_id, references(:processor), null: false
    end

    create table(:hard_drive) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :collection, :string, null: false
      add :capacity, :integer, null: false
      add :type, :string, null: false
      add :form_factor, :string
      add :sequential_read, :integer
      add :sequential_write, :integer
      add :random_read, :integer
      add :random_write, :integer
      add :tbw, :integer
      add :tdp, :integer
      add :brand_id, references(:brand), null: false
    end

    create unique_index(:hard_drive, [:slug])
    create unique_index(:hard_drive, [:collection, :capacity, :brand_id])

    create table(:product_category) do
      add :slug, :string, null: false
      add :title, :string, null: false
      add :path, :ltree, null: false
    end

    create unique_index(:product_category, [:path])

    create table(:product) do
      add :sku, :string, null: false
      add :slug, :string, null: false
      add :title, :string, null: false
      add :description, :string
      add :condition, :string, null: false
      add :list_price, :integer
      add :sale_price, :integer, null: false
      add :percentage_off, :decimal, null: false
      add :stock, :integer, null: false, default: 0
      add :type, :string
      add :category_id, references(:product_category)
      add :keywords, {:array, :string}, default: [], null: false
      add :barebone_id, references(:barebone)
      add :motherboard_id, references(:motherboard)
      add :processor_id, references(:processor)
      add :hard_drive_id, references(:hard_drive)
      add :memory_id, references(:memory)
      add :gpu_id, references(:gpu)
      add :chassis_id, references(:chassis)
      add :psu_id, references(:psu)
    end

    create unique_index(:product, [:sku])

    create table(:built) do
      add :slug, :string, null: false
      add :name, :string, null: false
      add :barebone_id, references(:barebone)
      add :motherboard_id, references(:motherboard)
      add :chassis_id, references(:chassis)
      # Embedded processor
      add :processor_id, references(:processor)
      add :barebone_product_id, references(:product)
      add :motherboard_product_id, references(:product)
      add :chassis_product_id, references(:product)
      add :barebone_price, :integer
      add :motherboard_price, :integer
      add :chassis_price, :integer
      add :total, :integer
    end

    create table(:built_psu) do
      add :built_id, references(:built), null: false
      add :psu_id, references(:psu), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end

    create table(:built_extension_device) do
      add :built_id, references(:built), null: false
      add :extension_device_id, references(:extension_device), null: false
      add :product_id, references(:product), null: false
      add :processor_index, :integer, null: false
      add :slot_type, :string, null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end

    create table(:built_processor) do
      add :built_id, references(:built), null: false
      add :processor_id, references(:processor), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end

    create table(:built_memory) do
      add :built_id, references(:built), null: false
      add :memory_id, references(:memory), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :processor_index, :integer, null: false
      add :slot_type, :string, null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end

    create table(:built_hard_drive) do
      add :built_id, references(:built), null: false
      add :hard_drive_id, references(:hard_drive), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :processor_index, :integer, null: false
      add :slot_type, :string, null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end

    create table(:built_gpu) do
      add :built_id, references(:built), null: false
      add :processor_index, :integer, null: false
      add :slot_type, :string, null: false
      add :gpu_id, references(:gpu), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :total, :integer, null: false
    end
  end

  defp create_extension(names) when is_list(names) do
    Enum.each(names, &create_extension/1)
  end

  defp create_extension(name) do
    execute(
      """
      CREATE EXTENSION IF NOT EXISTS "#{name}" SCHEMA pg_catalog;
      """,
      """
      DROP EXTENSION IF EXISTS "#{name}" SCHEMA pg_catalog;
      """
    )
  end
end
