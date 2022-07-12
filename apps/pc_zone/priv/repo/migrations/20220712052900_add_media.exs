defmodule PcZone.Repo.Migrations.AddMedia do
  use Ecto.Migration

  def change do
    create table(:medium, primary_key: false) do
      add :id, :string, size: 1024, primary_key: true, null: false
      add :remote_url, :string, size: 1024
      add :name, :string, size: 1024, null: false
      add :ext, :string
      add :mime, :string
      add :caption, :string
      add :width, :decimal, precision: 8, scale: 2
      add :height, :decimal, precision: 8, scale: 2
      add :size, :decimal, precision: 14, scale: 2
      add :status, :string, null: false
      add :blurhash, :string
      add :derived_files, {:array, :string}, null: false, default: []
      timestamps()
    end
  end
end
