defmodule Pczone.Store do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:code, :name, :merchant_id]
  @optional [:rate]

  schema "store" do
    field :code, :string
    field :name, :string
    field :merchant_id, :string
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
