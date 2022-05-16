defmodule Xeon.ExtensionDevice do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name]
  @optional [:brand_id]

  schema "extension_device" do
    field :name, :string, null: false
    belongs_to :brand, Xeon.Brand
    embeds_many :processor_slots, Xeon.ProcessorSlot
    embeds_many :memory_slots, Xeon.MemorySlot
    embeds_many :sata_slots, Xeon.SataSlot
    embeds_many :m2_slots, Xeon.M2Slot
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> cast_embed(:processor_slots)
    |> cast_embed(:memory_slots)
    |> cast_embed(:sata_slots)
    |> cast_embed(:m2_slots)
    |> validate_required(@required)
  end
end
