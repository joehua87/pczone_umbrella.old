defmodule Pczone.Heatsink do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :supported_types, :brand_id]
  @optional []

  schema "heatsink" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :supported_types, {:array, :string}
    belongs_to :brand, Pczone.Brand
    has_many :products, Pczone.Product
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
