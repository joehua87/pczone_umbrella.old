defmodule Xeon.Motherboard do
  use Ecto.Schema

  schema "motherboard" do
    field :name, :string
    field :max_memory_capacity, :integer
    belongs_to :chipset, Xeon.Chipset
    belongs_to :brand, Xeon.Brand
    field :note, :string
    embeds_many :memory_slots, Xeon.MemorySlot
    embeds_many :processor_slots, Xeon.ProcessorSlot
    embeds_many :sata_slots, Xeon.SataSlot
    embeds_many :m2_slots, Xeon.M2Slot
    embeds_many :pci_slots, Xeon.PciSlot
    field :memory_slots_count, :integer
    field :processor_slots_count, :integer
    field :sata_slots_count, :integer
    field :m2_slots_count, :integer
    field :pci_slots_count, :integer
    embeds_many :attributes, Xeon.AttributeGroup
    has_many :products, Xeon.Product
    many_to_many :processors, Xeon.Processor, join_through: Xeon.MotherboardProcessor
  end
end
