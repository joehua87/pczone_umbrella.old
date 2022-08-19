defmodule Pczone.BuiltTemplateVariantStore do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:store_id, :built_template_variant_id, :product_code, :variant_code]
  @optional []

  schema "built_template_variant_store" do
    belongs_to :store, Pczone.Store
    belongs_to :built_template_variant, Pczone.BuiltTemplateVariant
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
