defmodule Xeon.Memory do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:slug, :name, :capacity, :type, :brand_id]
  @optional [:description]

  schema "memory" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :capacity, :integer
    field :type, :string
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
  end
end
