defmodule Pczone.BuiltStore do
  use Pczone.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:built_id, :store_id, :product_code, :variant_code]
  @optional []

  schema "built_store" do
    belongs_to :built, Pczone.Built
    belongs_to :store, Pczone.Store
    field :product_code, :string
    field :variant_code, :string
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
