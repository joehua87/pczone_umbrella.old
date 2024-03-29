defmodule Pczone.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create_extension(["citext", "unaccent", "ltree"])

    create table(:enum) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :value, :string, null: false
    end

    create index(:enum, [:name])

    create table(:taxonomy) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :featured, :boolean, null: false, default: false
      add :position, :integer, default: 0
      add :description, :text
    end

    create unique_index(:taxonomy, [:code])
    create index(:taxonomy, [:featured])
    create index(:taxonomy, [:position])

    create table(:taxon) do
      add :name, :string, null: false
      add :path, :ltree, null: false
      add :description, :text
      add :translation, {:map, :string}
      add :taxonomy_id, references(:taxonomy), null: false
      add :featured, :boolean, null: false, default: false
      add :position, :integer, default: 0
    end

    create unique_index(:taxon, [:taxonomy_id, :path])
    create index(:taxon, [:path])
    create index(:taxon, [:taxonomy_id])
    create index(:taxon, [:featured])
    create index(:taxon, [:position])

    create table(:post) do
      add :slug, :string
      add :title, :string, null: false
      add :ref_type, :string
      add :ref_code, :string
      add :description, :text
      add :featured, :boolean, null: false, default: false
      add :position, :integer, default: 0
      add :md, :text
      add :rich_text, :map
      add :media, :map
      add :seo, :map
      add :state, :string
    end

    create unique_index(:post, [:slug])
    create unique_index(:post, [:ref_type, :ref_code])
    create index(:post, [:featured])
    create index(:post, [:position])

    create table(:post_taxon) do
      add :post_id, references(:post), null: false
      add :taxonomy_id, references(:taxonomy), null: false
      add :taxon_id, references(:taxon), null: false
    end

    create unique_index(:post_taxon, [:post_id, :taxon_id])
    create index(:post_taxon, [:taxonomy_id, :taxon_id])

    create table(:brand) do
      add :slug, :string, null: false
      add :name, :string, null: false
      add :post_id, references(:post)
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
      add :post_id, references(:post)
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
      add :post_id, references(:post)
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
      add :post_id, references(:post)
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
      add :post_id, references(:post)
    end

    create unique_index(:psu, [:slug])
    create unique_index(:psu, [:code])

    create table(:cooler) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :supported_types, {:array, :string}, null: false
      add :brand_id, references(:brand), null: false
      add :post_id, references(:post)
    end

    create unique_index(:cooler, [:slug])
    create unique_index(:cooler, [:code])

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
      add :post_id, references(:post)
    end

    create unique_index(:motherboard, [:slug])
    create unique_index(:motherboard, [:code])

    create table(:extension_device) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :type, :string, null: false
      add :brand_id, references(:brand), null: false
      add :processor_slots, :map, default: "[]"
      add :memory_slots, :map, default: "[]"
      add :sata_slots, :map, default: "[]"
      add :m2_slots, :map, default: "[]"
      add :post_id, references(:post)
    end

    create unique_index(:extension_device, [:slug])
    create unique_index(:extension_device, [:code])

    create table(:processor) do
      add :slug, :string, null: false
      add :code, :string, null: false
      add :name, :string, null: false
      add :sub, :string
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
      add :l1_cache, :decimal
      add :l2_cache, :decimal
      add :l3_cache, :decimal, null: false
      add :cores, :integer, null: false
      add :threads, :integer, null: false
      add :processor_graphics, :string
      add :gpu_id, references(:gpu)
      add :url, :string, null: false
      add :memory_types, {:array, :string}, null: false
      add :ecc_memory_supported, :boolean, default: false
      add :meta, :map
      add :attributes, :map, default: "[]"
      add :post_id, references(:post)
    end

    # Slug must be unique index
    create unique_index(:processor, [:slug])
    create unique_index(:processor, [:code])

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
      add :post_id, references(:post)
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
      add :post_id, references(:post)
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
      add :post_id, references(:post)
    end

    create unique_index(:hard_drive, [:slug])
    create unique_index(:hard_drive, [:collection, :capacity, :brand_id])

    create table(:product) do
      add :sku, :string
      add :code, :string, null: false
      add :slug, :string, null: false
      add :name, :string, null: false
      add :title, :string, null: false
      add :condition, :string, null: false
      add :component_type, :string
      add :is_bundled, :boolean, null: false
      add :featured, :boolean, null: false, default: false
      add :position, :integer, default: 0
      add :list_price, :integer
      add :sale_price, :integer, null: false
      add :percentage_off, :decimal, null: false
      add :cost, :integer
      add :stock, :integer, null: false, default: 0
      add :media, :map, null: false, default: "[]"
      add :post_id, references(:post)
    end

    create unique_index(:product, [:code])
    create unique_index(:product, [:slug])
    create index(:product, [:is_bundled])
    create index(:product, [:condition])
    create index(:product, [:list_price])
    create index(:product, [:sale_price])
    create index(:product, [:percentage_off])
    create index(:product, [:featured])
    create index(:product, [:position])

    create table(:component_product) do
      add :product_id, references(:product), null: false
      add :type, :string, null: false
      add :keywords, {:array, :string}, default: [], null: false
      add :barebone_id, references(:barebone)
      add :motherboard_id, references(:motherboard)
      add :processor_id, references(:processor)
      add :hard_drive_id, references(:hard_drive)
      add :memory_id, references(:memory)
      add :gpu_id, references(:gpu)
      add :chassis_id, references(:chassis)
      add :psu_id, references(:psu)
      add :cooler_id, references(:cooler)
    end

    create unique_index(:component_product, [:product_id])

    create table(:bundled_product) do
      add :product_id, references(:product), null: false
      add :discount, :integer, null: false, default: 0
      add :is_customize, :boolean, null: false, default: false
    end

    create table(:bundled_product_item) do
      add :bundled_product_id, references(:bundled_product), null: false
      add :product_id, references(:product), null: false
    end

    create table(:product_taxon) do
      add :product_id, references(:product), null: false
      add :taxonomy_id, references(:taxonomy), null: false
      add :taxon_id, references(:taxon), null: false
    end

    create unique_index(:product_taxon, [:product_id, :taxon_id])
    create index(:product_taxon, [:taxonomy_id, :taxon_id])

    create table(:built_template) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :slug, :string, null: false
      add :title, :string, null: false
      add :media, :map, null: false, default: "[]"
      add :body_template, :string, null: false
      add :featured, :boolean, null: false, default: false
      add :position, :integer, default: 0
      add :barebone_id, references(:barebone), null: false
      add :barebone_product_id, references(:product), null: false
      add :option_value_seperator, :string, null: false
      add :option_types, {:array, :string}, null: false
      add :config, :map, null: false, default: %{}
      add :post_id, references(:post)
    end

    create unique_index(:built_template, [:code])
    create unique_index(:built_template, [:slug])
    create index(:built_template, [:featured])
    create index(:built_template, [:position])

    create table(:built_template_processor) do
      add :built_template_id, references(:built_template, on_delete: :delete_all), null: false
      add :processor_id, references(:processor), null: false
      add :processor_product_id, references(:product), null: false
      add :processor_quantity, :integer, null: false, default: 1
      add :processor_label, :string
      add :gpu_id, references(:gpu)
      add :gpu_product_id, references(:product)
      add :gpu_quantity, :integer, null: false, default: 0
      add :gpu_label, :string, default: ""
    end

    create unique_index(:built_template_processor, [
             :built_template_id,
             :processor_label,
             :gpu_label
           ])

    create table(:built_template_memory) do
      add :built_template_id, references(:built_template, on_delete: :delete_all), null: false
      add :memory_id, references(:memory), null: false
      add :memory_product_id, references(:product), null: false
      add :quantity, :integer, null: false, default: 1
      add :label, :string
    end

    create unique_index(:built_template_memory, [:built_template_id, :label])

    create table(:built_template_hard_drive) do
      add :built_template_id, references(:built_template, on_delete: :delete_all), null: false
      add :hard_drive_id, references(:hard_drive), null: false
      add :hard_drive_product_id, references(:product), null: false
      add :quantity, :integer, null: false, default: 1
      add :label, :string
    end

    create unique_index(:built_template_hard_drive, [:built_template_id, :label])

    create table(:built_template_taxon) do
      add :built_template_id, references(:built_template), null: false
      add :taxonomy_id, references(:taxonomy), null: false
      add :taxon_id, references(:taxon), null: false
    end

    create unique_index(:built_template_taxon, [:built_template_id, :taxon_id])
    create index(:built_template_taxon, [:taxonomy_id, :taxon_id])

    create table(:built) do
      add :slug, :string, null: false
      add :name, :string, null: false
      add :built_template_id, references(:built_template)
      add :option_values, {:array, :string}
      add :barebone_id, references(:barebone)
      add :motherboard_id, references(:motherboard)
      add :chassis_id, references(:chassis)
      add :barebone_product_id, references(:product)
      add :motherboard_product_id, references(:product)
      add :chassis_product_id, references(:product)
      add :stock, :integer
      add :price, :integer
      add :position, :integer
      add :state, :string, default: "published"
    end

    create unique_index(:built, [:built_template_id, :option_values])

    create table(:built_psu) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :psu_id, references(:psu), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:built_psu, [:built_id, :psu_id])

    create table(:built_cooler) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :cooler_id, references(:cooler), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:built_cooler, [:built_id, :cooler_id])

    create table(:built_extension_device) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :extension_device_id, references(:extension_device), null: false
      add :product_id, references(:product), null: false
      add :processor_index, :integer, null: false
      add :slot_type, :string, null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:built_extension_device, [:built_id, :extension_device_id])

    create table(:built_processor) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :processor_id, references(:processor), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :quantity, :integer, null: false
    end

    create unique_index(:built_processor, [:built_id, :processor_id])

    create table(:built_memory) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :memory_id, references(:memory), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :processor_index, :integer
      add :slot_type, :string
      add :quantity, :integer
    end

    create unique_index(:built_memory, [:built_id, :memory_id])

    create table(:built_hard_drive) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :hard_drive_id, references(:hard_drive), null: false
      add :product_id, references(:product), null: false
      add :extension_device_id, references(:extension_device)
      add :processor_index, :integer
      add :slot_type, :string
      add :quantity, :integer
    end

    create unique_index(:built_hard_drive, [:built_id, :hard_drive_id])

    create table(:built_gpu) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :gpu_id, references(:gpu), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
      add :processor_index, :integer
      add :slot_type, :string
    end

    create unique_index(:built_gpu, [:built_id, :gpu_id])
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
