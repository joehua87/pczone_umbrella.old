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
      add :code, :string, null: false
      add :product_id, references(:product), null: false
      add :quantity, :integer, null: false
      add :location, :string, null: false
      add :media, :map, null: false, default: "[]"
      add :data, :map, null: false, default: %{}
    end

    create unique_index(:product_stock, [:product_id, :code])

    create table(:stock_movement) do
      add :state, :string, null: false
      add :submitted_at, :utc_datetime
      timestamps()
    end

    create table(:stock_movement_item) do
      add :stock_movement_id, references(:stock_movement), null: false
      add :product_id, references(:product), null: false
      add :code, :string, null: false
      add :source_location, :string, null: false
      add :destination_location, :string, null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:stock_movement_item, [:stock_movement_id, :product_id, :code])

    create table(:customer) do
      add :name, :string, null: false
      add :phone, :string, null: false
      add :tax_info, :map
      add :addresses, :map, null: false
      add :labels, :map, null: false, default: %{}
      add :user_id, references(:user)
      timestamps()
    end

    create table(:order) do
      add :code, :string, null: false
      add :user_id, references(:user)
      add :customer_id, references(:customer)
      add :billing_address, :map
      add :shipping_address, :map
      add :tax_info, :map
      add :state, :string
      add :total, :integer, null: false
      add :token, :string, null: false
      add :submitted_at, :utc_datetime
      add :submitted_by_id, references(:user)
      add :approved_at, :utc_datetime
      add :approved_by_id, references(:user)
      add :canceled_at, :utc_datetime
      add :canceled_by_id, references(:user)
      add :shipped_at, :utc_datetime
      add :completed_at, :utc_datetime
      timestamps()
    end

    create unique_index(:order, [:code])

    create table(:order_built) do
      add :order_id, references(:order), null: false
      add :built_id, references(:built)
      add :image, :map
      add :built_template_name, :string, null: false
      add :built_name, :string
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :amount, :integer, null: false
      timestamps()
    end

    create unique_index(:order_built, [:order_id, :built_id])

    create table(:order_item) do
      add :order_id, references(:order), null: false
      add :product_id, references(:product)
      add :image, :map
      add :product_name, :string, null: false
      add :from_built, :boolean, default: false, null: false
      add :price, :integer, null: false
      add :quantity, :integer, null: false
      add :amount, :integer, null: false
      timestamps()
    end

    create unique_index(:order_item, [:order_id, :product_id])

    create table(:order_adjustment) do
      add :order_id, references(:order), null: false
      add :type, :string, null: false
      add :amount, :integer, null: false
      timestamps()
    end

    create table(:order_item_stock) do
      add :order_id, references(:order), null: false
      add :order_item_id, references(:order_item), null: false
      add :product_id, references(:product), null: false
      add :code, :string, null: false
      add :quantity, :integer, null: false
      add :warranty_expiration_at, :utc_datetime, null: false
    end
  end
end
