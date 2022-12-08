defmodule Pczone.StoreVariant do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:product_code, :name]
  @optional [:description, :sold, :stats, :created_at]

  schema "store_variant" do
    belongs_to :store_product, Pczone.StoreProduct
    belongs_to :store, Pczone.Store
    field :product_code, :string
    field :variant_code, :string
    field :name, :string
    belongs_to :product, Pczone.Product
    belongs_to :built, Pczone.Built
    timestamps()
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:images)
    |> cast_embed(:options)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
