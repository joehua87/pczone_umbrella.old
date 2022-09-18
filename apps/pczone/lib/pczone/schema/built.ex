defmodule Pczone.Built do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :name]
  @optional [
    :key,
    :built_template_id,
    :option_values,
    :barebone_id,
    :motherboard_id,
    :chassis_id,
    :barebone_product_id,
    :motherboard_product_id,
    :chassis_product_id,
    :price,
    :position,
    :state
  ]

  schema "built" do
    field :key, :string
    field :slug, :string
    field :name, :string
    belongs_to :built_template, Pczone.BuiltTemplate
    field :option_values, {:array, :string}
    belongs_to :barebone, Pczone.Barebone
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :chassis, Pczone.Chassis
    belongs_to :barebone_product, Pczone.Product
    belongs_to :motherboard_product, Pczone.Product
    belongs_to :chassis_product, Pczone.Product
    field :price, :integer
    field :position, :integer
    field :state, Ecto.Enum, default: :published, values: [:published, :archived]
    has_many :built_psus, Pczone.BuiltPsu
    has_many :built_coolers, Pczone.BuiltCooler
    has_many :built_extension_devices, Pczone.BuiltExtensionDevice
    has_many :built_processors, Pczone.BuiltProcessor
    has_many :built_memories, Pczone.BuiltMemory
    has_many :built_hard_drives, Pczone.BuiltHardDrive
    has_many :built_gpus, Pczone.BuiltGpu
    has_many :built_stores, Pczone.BuiltStore
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
