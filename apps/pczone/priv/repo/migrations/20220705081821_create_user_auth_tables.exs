defmodule Pczone.Repo.Migrations.CreateUserAuthTables do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :username, :citext, null: false
      add :email, :citext, null: false
      add :phone, :string
      add :name, :string, null: false
      add :hashed_password, :string, null: false
      add :avatar, :map
      add :bio, :text
      add :role, :string
      add :confirmed_at, :naive_datetime
      add :field_values, :map, default: "[]", null: false
      timestamps()
    end

    create unique_index(:user, [:username])
    create unique_index(:user, [:email])

    create table(:user_token) do
      add :user_id, references(:user, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create table(:user_address) do
      add :user_id, references(:user), null: false
      add :address, :map, null: false
    end

    create index(:user_address, [:user_id])

    create table(:user_tax_info) do
      add :user_id, references(:user), null: false
      add :tax_info, :map, null: false
    end

    create index(:user_tax_info, [:user_id])

    create index(:user_token, [:user_id])
    create unique_index(:user_token, [:context, :token])
  end
end
