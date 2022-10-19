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

    create table(:built_template_store) do
      add :built_template_id, references(:built_template, on_delete: :delete_all), null: false
      add :store_id, references(:store), null: false
      add :product_code, :string, null: false
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

    # create table(:product_store) do
    #   add :store_id, references(:store), null: false
    #   add :product_id, references(:product), null: false
    #   add :product_code, :string, null: false
    #   add :variant_code, :string, null: false
    # end

    # create unique_index(:product_store, [:store_id, :product_id])
  end
end
