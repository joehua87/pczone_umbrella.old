defmodule Xeon.Psu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :name, :wattage, :form_factor, :brand_id]
  @optional []

  schema "psu" do
    field :slug, :string
    field :name, :string
    field :wattage, :integer
    field :form_factor, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
    |> validate_required(@required)
  end
end
