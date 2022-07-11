defmodule PcZone.Repo.Migrations.ManageReports do
  use Ecto.Migration

  def change do
    create table(:report) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :path, :string, null: false
      add :category, :string, null: false
      add :size, :integer, null: false
      timestamps()
    end
  end
end
