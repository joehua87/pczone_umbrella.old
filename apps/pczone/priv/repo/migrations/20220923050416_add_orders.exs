defmodule Pczone.Repo.Migrations.AddOrders do
  use Ecto.Migration

  def change do
    create table(:built_product) do
      add :built_id, references(:built), null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:built_product, [:built_id, :product_id])

    create table(:product_stock) do
      add :code, :string
      add :lot, :string
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
      add :location, :string, null: false
      add :images, :map, null: false, default: "[]"
      add :data, :map, null: false, default: %{}
    end

    create unique_index(:product_stock, [:code])

    create table(:customer) do
      add :name, :string, null: false
      add :phone, :string, null: false
      add :tax_info, :map
      add :addresses, :map, null: false
      add :labels, :map, null: false, default: %{}
      add :user_id, references(:user)
      timestamps()
    end

    create table(:stock_movement) do
      add :source_location, :string, null: false
      add :destination_location, :string, null: false
      timestamps(updated_at: false)
    end

    create table(:stock_movement_item) do
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
    end

    create table(:order) do
      add :code, :string, null: false
      add :customer_id, references(:customer), null: false
      add :billing_address, :map
      add :shipping_address, :map, null: false
      add :tax_info, :map
      add :state, :string
      add :total, :integer, null: false
      timestamps()
    end

    create table(:order_item) do
      add :order_id, references(:order), null: false
      add :product_id, references(:product), null: false
      add :product_stock_id, references(:product_stock), null: false
      add :warranty_expiration_at, :utc_datetime, null: false
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :amount, :integer, null: false
    end
  end
end
