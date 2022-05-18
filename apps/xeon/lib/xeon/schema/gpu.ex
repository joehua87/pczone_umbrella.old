defmodule Xeon.Gpu do
  use Ecto.Schema

  schema "gpu" do
    field :name, :string
    field :slot_type, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
