defmodule PcZone.Built do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :name]
  @optional [
    :barebone_id,
    :motherboard_id,
    :chassis_id,
    :barebone_product_id,
    :motherboard_product_id,
    :chassis_product_id,
    :barebone_price,
    :motherboard_price,
    :chassis_price,
    :usable,
    :total
  ]

  schema "built" do
    field :slug, :string, null: false
    field :name, :string, null: false
    belongs_to :barebone, PcZone.Barebone
    belongs_to :motherboard, PcZone.Motherboard
    belongs_to :chassis, PcZone.Chassis
    belongs_to :processor, PcZone.Processor
    belongs_to :barebone_product, PcZone.Product
    belongs_to :motherboard_product, PcZone.Product
    belongs_to :chassis_product, PcZone.Product
    field :barebone_price, :integer
    field :motherboard_price, :integer
    field :chassis_price, :integer
    field :usable, :boolean, default: false
    field :total, :integer
    has_many :built_psus, PcZone.BuiltPsu
    has_many :built_heatsinks, PcZone.BuiltHeatsink
    has_many :built_extension_devices, PcZone.BuiltExtensionDevice
    has_many :built_processors, PcZone.BuiltProcessor
    has_many :built_memories, PcZone.BuiltMemory
    has_many :built_hard_drives, PcZone.BuiltHardDrive
    has_many :built_gpus, PcZone.BuiltGpu
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
