defmodule Xeon.HardDrive do
  use Ecto.Schema

  schema "hard_drive" do
    field :name, :string
    field :capacity, :string
    field :type, Ecto.Enum, values: [:sata_3_5, :sata_2_5, :msata, :m2_sata, :m2_nvme]
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end
end
