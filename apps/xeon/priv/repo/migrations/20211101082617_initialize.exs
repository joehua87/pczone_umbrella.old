defmodule Xeon.Repo.Migrations.Initialize do
  use Ecto.Migration

  def change do
    create table(:chipset) do
      add :name, :string, null: false
    end

    create table(:motherboard) do
      add :name, :string, null: false
      add :max_memory_capacity, :integer, null: false
      add :memory_slot, :integer, null: false
      add :processor_slot, :integer, null: false, default: 1
      add :chipset_id, references(:chipset), null: false
    end

    create table(:processor_family) do
      add :name, :string, null: false
    end

    create table(:processor) do
      add :name, :string, null: false
      add :processor_family_id, references(:processor_family), null: false
    end

    create table(:memory_type) do
      add :name, :string, null: false
    end

    create table(:brand) do
      add :name, :string, null: false
    end

    create table(:memory) do
      add :name, :string, null: false
      add :brand_id, references(:brand), null: false
      add :memory_type_id, references(:memory_type), null: false
    end

    create table(:motherboard_memory_type) do
      add :motherboard_id, references(:motherboard), null: false
      add :memory_type_id, references(:memory_type), null: false
    end

    create table(:motherboard_processor_family) do
      add :motherboard_id, references(:motherboard), null: false
      add :processor_family_id, references(:processor_family), null: false
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
