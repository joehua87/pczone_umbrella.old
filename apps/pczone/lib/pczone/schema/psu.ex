defmodule Pczone.Psu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :wattage, :form_factor, :brand_id]
  @optional []

  schema "psu" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :wattage, :integer
    field :form_factor, :string
    belongs_to :brand, Pczone.Brand
    belongs_to :post, Pczone.Post
    many_to_many :products, Pczone.Product, join_through: Pczone.ComponentProduct
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
