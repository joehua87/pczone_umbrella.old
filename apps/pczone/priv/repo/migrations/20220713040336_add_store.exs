defmodule Pczone.Repo.Migrations.AddStore do
  use Ecto.Migration

  def change do
    create table(:store) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :platform, :string, null: false
      add :email, :string
      add :phone, :string
      add :cookie, :text
      add :merchant_id, :string
      add :rate, :decimal, null: false, default: 1
    end

    create unique_index(:store, [:code])

    create table(:store_product) do
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :product_id, references(:product, on_delete: :delete_all)
      add :built_template_id, references(:built_template, on_delete: :delete_all)
      add :options, :map, null: false, default: "[]"
      add :images, :map, default: "[]"
      add :sold, :integer
      add :stats, :map, default: %{}
      add :created_at, :utc_datetime
      timestamps()
    end

    create unique_index(:store_product, [:store_id, :product_code])

    create table(:store_variant) do
      add :store_product_id, references(:store_product), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :variant_code, :string, null: false
      add :name, :string
      add :product_id, references(:product, on_delete: :delete_all)
      add :built_id, references(:built, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:store_variant, [:store_id, :variant_code])

    create table(:built_template_store) do
      add :built_template_id, references(:built_template, on_delete: :delete_all), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :name, :string
      add :variants, :map, null: false, default: "[]"
      add :update_variants_at, :utc_datetime
    end

    create unique_index(:built_template_store, [:built_template_id, :store_id])

    create table(:built_store) do
      add :built_id, references(:built, on_delete: :delete_all), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
      add :variant_code, :string, null: false
    end

    create unique_index(:built_store, [:built_id, :store_id])
  end
end
