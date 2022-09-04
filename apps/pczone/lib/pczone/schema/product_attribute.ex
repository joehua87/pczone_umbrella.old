defmodule Pczone.ProductAttribute do
  use Ecto.Schema

  schema "product_attribute" do
    belongs_to :product, Pczone.Product
    belongs_to :attribute, Pczone.Attribute
    belongs_to :attribute_item, Pczone.AttributeItem
  end
end
