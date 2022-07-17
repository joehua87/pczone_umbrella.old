defmodule Pczone.Motherboard do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder
  @required [:slug, :code, :name, :max_memory_capacity, :chipset_id, :brand_id]
  @optional [
    :note,
    :chassis_form_factors,
    :memory_slots_count,
    :processor_slots_count,
    :sata_slots_count,
    :m2_slots_count,
    :pci_slots_count
  ]

  schema "motherboard" do
    field :slug, :string
    field :code, :string
    field :name, :string
    field :max_memory_capacity, :integer
    belongs_to :chipset, Pczone.Chipset
    belongs_to :brand, Pczone.Brand
    field :note, :string
    field :chassis_form_factors, {:array, :string}
    embeds_many :memory_slots, Pczone.MemorySlot
    embeds_many :processor_slots, Pczone.ProcessorSlot
    embeds_many :sata_slots, Pczone.SataSlot
    embeds_many :m2_slots, Pczone.M2Slot
    embeds_many :pci_slots, Pczone.PciSlot
    field :memory_slots_count, :integer
    field :processor_slots_count, :integer
    field :sata_slots_count, :integer
    field :m2_slots_count, :integer
    field :pci_slots_count, :integer
    embeds_many :attributes, Pczone.AttributeGroup
    has_many :products, Pczone.Product
    many_to_many :processors, Pczone.Processor, join_through: Pczone.MotherboardProcessor
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> cast_embed(:memory_slots)
    |> cast_embed(:processor_slots)
    |> cast_embed(:sata_slots)
    |> cast_embed(:m2_slots)
    |> cast_embed(:pci_slots)
    |> cast_embed(:attributes)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> cast_embed(:memory_slots)
    |> cast_embed(:processor_slots)
    |> cast_embed(:sata_slots)
    |> cast_embed(:m2_slots)
    |> cast_embed(:pci_slots)
    |> cast_embed(:attributes)
    |> validate_required(@required)
  end
end
