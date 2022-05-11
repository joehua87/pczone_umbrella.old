defmodule Xeon.Motherboard do
  use Ecto.Schema

  schema "motherboard" do
    field :name, :string
    field :max_memory_capacity, :integer
    field :memory_types, {:array, :string}
    field :memory_slots, :integer
    field :processor_slots, :integer, default: 1
    belongs_to :chipset, Xeon.Chipset
    belongs_to :brand, Xeon.Brand
    field :note, :string
    embeds_many :hard_drive_slots, Xeon.DriveSlot
    embeds_many :pci_slots, Xeon.PciSlot
    embeds_many :attributes, Xeon.AttributeGroup
    has_many :products, Xeon.Product
    many_to_many :processors, Xeon.Processor, join_through: Xeon.MotherboardProcessor
  end
end
