defmodule Pczone.SimpleBuiltVariantStore do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:store_id, :simple_built_variant_id, :product_code, :variant_code]
  @optional []

  schema "simple_built_variant_store" do
    belongs_to :store, Pczone.Store
    belongs_to :simple_built_variant, Pczone.SimpleBuiltVariant
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
