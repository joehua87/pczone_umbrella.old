defmodule Pczone.BuiltTemplateStore do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:built_template_id, :store_id, :product_code]
  @optional [:variants, :update_variants_at]

  schema "built_template_store" do
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :store, Pczone.Memory
    field :product_code, :string
    field :variants, {:array, :map}
    field :update_variants_at, :utc_datetime
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
