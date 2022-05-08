defmodule Xeon.Chassis do
  use Ecto.Schema

  schema "chassis" do
    field :name, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
