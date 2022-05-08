defmodule Xeon.Psu do
  use Ecto.Schema

  schema "psu" do
    field :name, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
