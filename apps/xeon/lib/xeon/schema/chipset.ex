defmodule Xeon.Chipset do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name]
  @optional []

  schema "chipset" do
    field :name, :string, null: false
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
