defmodule Pczone.Repo.Migrations.AddStore do
  use Ecto.Migration

  def change do
    create table(:store) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :merchant_id, :string, null: false
      add :rate, :decimal, null: false, default: 1
    end

    create unique_index(:store, [:code])

    create table(:simple_built_store) do
      add :simple_built_id, references(:simple_built), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :variants, :map, null: false, default: "[]"
      add :update_variants_at, :utc_datetime
    end

    create unique_index(:simple_built_store, [:simple_built_id, :store_id])

    create table(:simple_built_variant_store) do
      add :simple_built_variant_id, references(:simple_built_variant), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :variant_code, :string, null: false
    end

    create unique_index(:simple_built_variant_store, [:simple_built_variant_id, :store_id])

    # create table(:product_store) do
    #   add :store_id, references(:store), null: false
    #   add :product_id, references(:product), null: false
    #   add :product_code, :string, null: false
    #   add :variant_code, :string, null: false
    # end

    # create unique_index(:product_store, [:store_id, :product_id])
  end
end
