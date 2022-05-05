defmodule Xeon.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create table(:chipset) do
      add :shortname, :string, null: false
      add :code_name, :string, null: false
      add :name, :string, null: false
      add :launch_date, :string, null: false
      add :collection_name, :string, null: false
      add :vertical_segment, :string, null: false
      add :status, :string, null: false
      add :attributes, :map, null: false
    end

    create unique_index(:chipset, [:shortname])

    create table(:motherboard_type) do
      add :name, :string, null: false
    end

    create table(:motherboard) do
      add :name, :string, null: false
      add :max_memory_capacity, :integer, null: false
      add :memory_slot, :integer, null: false
      add :processor_slot, :integer, null: false, default: 1
      add :chipset, :string, null: false
      add :socket, :string, null: false
      add :note, :string
    end

    create unique_index(:motherboard, [:name])

    create table(:processor_collection) do
      add :name, :string, null: false
      add :code, :string
      add :socket, :string
    end

    create unique_index(:processor_collection, [:name])

    create table(:processor) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :sub, :string, null: false
      add :collection_id, references(:processor_collection)
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
      add :url, :string, null: false
      add :memory_types, {:array, :string}, null: false
      add :ecc_memory_supported, :boolean, default: false
      add :meta, :map
      add :attributes, :map, default: "[]"
    end

    create unique_index(:processor, [:name, :sub])

    create table(:processor_score) do
      add :processor_id, references(:processor), null: false
      add :test_name, :string, null: false
      add :single, :integer, null: false
      add :multi, :integer, null: false
    end

    create unique_index(:processor_score, [:processor_id, :test_name])

    create table(:memory_type) do
      add :name, :string, null: false
    end

    create unique_index(:memory_type, [:name])

    create table(:brand) do
      add :name, :string, null: false
    end

    create table(:memory) do
      add :name, :string, null: false
      add :capacity, :integer, null: false
      add :brand_id, references(:brand)
      add :memory_type_id, references(:memory_type), null: false
    end

    create table(:motherboard_memory_type) do
      add :motherboard_id, references(:motherboard), null: false
      add :memory_type_id, references(:memory_type), null: false
    end

    create table(:motherboard_processor_collection) do
      add :motherboard_id, references(:motherboard), null: false
      add :processor_collection_id, references(:processor_collection), null: false
    end

    create table(:skeleton) do
      add :name, :string, null: false
      add :custom_motherboard, :boolean, null: false
      add :custom_cpu, :boolean, null: false
      add :custom_ram, :boolean, null: false
      add :custom_drive, :boolean, null: false
      add :custom_case, :boolean, null: false
      add :custom_psu, :boolean, null: false
      add :min_psu, :integer, null: false
    end

    create table(:skeleton_motherboard) do
      add :skeleton_id, references(:skeleton), null: false
      add :motherboard_id, references(:motherboard), null: false
    end
  end
end
