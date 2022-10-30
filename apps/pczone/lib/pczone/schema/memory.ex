defmodule Pczone.Memory do
  use Pczone.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:slug, :code, :name, :capacity, :type, :brand_id]
  @optional [:description]

  schema "memory" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :description, :string
    field :capacity, :integer
    field :type, :string
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
