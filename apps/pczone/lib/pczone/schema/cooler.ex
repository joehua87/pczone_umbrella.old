defmodule Pczone.Cooler do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :supported_types, :brand_id]
  @optional []

  schema "cooler" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :supported_types, {:array, :string}
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
  end
end
