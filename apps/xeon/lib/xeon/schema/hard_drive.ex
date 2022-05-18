defmodule Xeon.HardDrive do
  use Ecto.Schema

  schema "hard_drive" do
    field :name, :string
    field :capacity, :string
    field :slot_type, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
