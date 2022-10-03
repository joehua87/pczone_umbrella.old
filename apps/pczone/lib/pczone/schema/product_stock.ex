defmodule Pczone.ProductStock do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:product_id, :quantity, :location]
  @optional [:code, :media, :data]

  schema "product_stock" do
    field :code, :string
    belongs_to :product, Pczone.Product
    field :quantity, :integer
    field :location, :string
    field :data, :map
    embeds_many :media, Pczone.EmbeddedMedium, on_replace: :delete
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:media)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
