defmodule Xeon.HardDrive do
  use Ecto.Schema

  schema "hard_drive" do
    field :name, :string
    field :capacity, :string
    field :type, Ecto.Enum, values: [:sata_3_5, :sata_2_5, :msata, :nvme_3x4, :nvme_4x4]
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
