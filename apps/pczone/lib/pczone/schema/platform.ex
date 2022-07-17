defmodule Pczone.Platform do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:code, :name]
  @optional [:rate]

  schema "platform" do
    field :code, :string
    field :name, :string
    field :rate, :decimal, default: 1
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
