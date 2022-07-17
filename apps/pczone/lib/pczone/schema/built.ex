defmodule Pczone.Built do
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
    field :slug, :string
    field :name, :string
    belongs_to :barebone, Pczone.Barebone
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :chassis, Pczone.Chassis
    belongs_to :processor, Pczone.Processor
    belongs_to :barebone_product, Pczone.Product
    belongs_to :motherboard_product, Pczone.Product
    belongs_to :chassis_product, Pczone.Product
    field :barebone_price, :integer
    field :motherboard_price, :integer
    field :chassis_price, :integer
    field :usable, :boolean, default: false
    field :total, :integer
    has_many :built_psus, Pczone.BuiltPsu
    has_many :built_heatsinks, Pczone.BuiltHeatsink
    has_many :built_extension_devices, Pczone.BuiltExtensionDevice
    has_many :built_processors, Pczone.BuiltProcessor
    has_many :built_memories, Pczone.BuiltMemory
    has_many :built_hard_drives, Pczone.BuiltHardDrive
    has_many :built_gpus, Pczone.BuiltGpu
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
