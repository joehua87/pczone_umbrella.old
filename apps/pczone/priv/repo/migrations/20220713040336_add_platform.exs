defmodule Pczone.Repo.Migrations.AddPlatform do
  use Ecto.Migration

  def change do
    create table(:platform) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :merchant_id, :string, null: false
      add :rate, :decimal, null: false, default: 1
    end

    create unique_index(:platform, [:code])

    create table(:simple_built_platform) do
      add :simple_built_id, references(:simple_built), null: false
      add :platform_id, references(:platform), null: false
      add :product_code, :string, null: false
      add :variants, :map, null: false, default: "[]"
      add :update_variants_at, :utc_datetime
    end

    create unique_index(:simple_built_platform, [:simple_built_id, :platform_id])

    create table(:simple_built_variant_platform) do
      add :simple_built_variant_id, references(:simple_built_variant), null: false
      add :platform_id, references(:platform), null: false
      add :product_code, :string, null: false
      add :variant_code, :string, null: false
    end

    create unique_index(:simple_built_variant_platform, [:simple_built_variant_id, :platform_id])

    # create table(:product_platform) do
    #   add :platform_id, references(:platform), null: false
    #   add :product_id, references(:product), null: false
    #   add :product_code, :string, null: false
    #   add :variant_code, :string, null: false
    # end

    # create unique_index(:product_platform, [:platform_id, :product_id])
  end
end
