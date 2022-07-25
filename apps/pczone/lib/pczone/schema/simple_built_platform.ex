defmodule Pczone.SimpleBuiltPlatform do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:platform_id, :simple_built_id, :product_code]
  @optional [:variants, :update_variants_at]

  schema "simple_built_platform" do
    belongs_to :platform, Pczone.Memory
    belongs_to :simple_built, Pczone.SimpleBuilt
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
