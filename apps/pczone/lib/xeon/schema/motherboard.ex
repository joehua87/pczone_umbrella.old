defmodule PcZone.Motherboard do
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
    belongs_to :chipset, PcZone.Chipset
    belongs_to :brand, PcZone.Brand
    field :note, :string
    field :chassis_form_factors, {:array, :string}
    embeds_many :memory_slots, PcZone.MemorySlot
    embeds_many :processor_slots, PcZone.ProcessorSlot
    embeds_many :sata_slots, PcZone.SataSlot
    embeds_many :m2_slots, PcZone.M2Slot
    embeds_many :pci_slots, PcZone.PciSlot
    field :memory_slots_count, :integer
    field :processor_slots_count, :integer
    field :sata_slots_count, :integer
    field :m2_slots_count, :integer
    field :pci_slots_count, :integer
    embeds_many :attributes, PcZone.AttributeGroup
    has_many :products, PcZone.Product
    many_to_many :processors, PcZone.Processor, join_through: PcZone.MotherboardProcessor
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
