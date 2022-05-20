defmodule Xeon.Built do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :motherboard_id, :chassis_id]
  @optional [:barebone_id]

  schema "built" do
    field :name, :string, null: false
    belongs_to :barebone, Xeon.Barebone
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :chassis, Xeon.Chassis
    belongs_to :barebone_product, Xeon.Product
    belongs_to :motherboard_product, Xeon.Product
    belongs_to :chassis_product, Xeon.Product
    has_many :built_psus, Xeon.BuiltPsu
    has_many :built_extension_devices, Xeon.BuiltExtensionDevice
    has_many :built_processors, Xeon.BuiltProcessor
    has_many :built_memories, Xeon.BuiltMemory
    has_many :built_hard_drives, Xeon.BuiltHardDrive
    has_many :built_gpus, Xeon.BuiltGpu
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
