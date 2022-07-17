defmodule Pczone.ExtensionDevice do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :code, :name, :type, :brand_id]
  @optional []

  schema "extension_device" do
    field :slug, :string, null: false
    field :code, :string, null: false
    field :name, :string, null: false
    field :type, :string, null: false
    belongs_to :brand, Pczone.Brand
    embeds_many :processor_slots, Pczone.ProcessorSlot
    embeds_many :memory_slots, Pczone.MemorySlot
    embeds_many :sata_slots, Pczone.SataSlot
    embeds_many :m2_slots, Pczone.M2Slot
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

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
