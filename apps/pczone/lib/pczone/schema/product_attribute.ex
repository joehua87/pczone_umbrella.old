defmodule Pczone.ProductAttribute do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:product_id, :attribute_id, :attribute_item_id]
  @optional []

  schema "product_attribute" do
    belongs_to :product, Pczone.Product
    belongs_to :attribute, Pczone.Attribute
    belongs_to :attribute_item, Pczone.AttributeItem
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
