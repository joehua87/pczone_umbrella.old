defmodule PcZone.SimpleBuiltVariantPlatform do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:platform_id, :simple_built_variant_id, :product_code, :variant_code]
  @optional []

  schema "simple_built_variant_platform" do
    belongs_to :platform, PcZone.Memory
    belongs_to :simple_built_variant, PcZone.SimpleBuiltVariant
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
