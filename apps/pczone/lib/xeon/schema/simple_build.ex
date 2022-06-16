defmodule PcZone.SimpleBuild do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:code, :name]
  @optional []

  schema "simple_build" do
    field :code, :string, null: false
    field :name, :string, null: false
    belongs_to :barebone, PcZone.Barebone
    belongs_to :barebone_product, PcZone.Product
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
