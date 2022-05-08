defmodule Xeon.Barebone do
  use Ecto.Schema

  schema "barebone" do
    field :name, :string
    belongs_to :motherboard, Xeon.Motherboard
    has_many :products, Xeon.Product
  end
end
