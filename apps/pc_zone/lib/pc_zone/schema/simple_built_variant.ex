defmodule PcZone.SimpleBuiltVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [
    :simple_built_id,
    :barebone_id,
    :barebone_product_id,
    :barebone_price,
    :processor_id,
    :processor_product_id,
    :processor_price,
    :processor_quantity,
    :processor_amount,
    :memory_id,
    :memory_product_id,
    :memory_price,
    :memory_quantity,
    :memory_amount,
    :hard_drive_id,
    :hard_drive_product_id,
    :hard_drive_price,
    :hard_drive_quantity,
    :hard_drive_amount,
    :option_values,
    :total,
    :config
  ]

  @optional [
    :gpu_id,
    :gpu_product_id,
    :gpu_price,
    :gpu_quantity,
    :gpu_amount
  ]

  schema "simple_built_variant" do
    belongs_to :simple_built, PcZone.SimpleBuilt
    belongs_to :barebone, PcZone.Barebone
    belongs_to :barebone_product, PcZone.Product
    field :barebone_price, :integer
    belongs_to :processor, PcZone.Processor
    belongs_to :processor_product, PcZone.Product
    field :processor_price, :integer
    field :processor_quantity, :integer
    field :processor_amount, :integer
    belongs_to :gpu, PcZone.Gpu
    belongs_to :gpu_product, PcZone.Product
    field :gpu_price, :integer
    field :gpu_quantity, :integer
    field :gpu_amount, :integer
    belongs_to :memory, PcZone.Memory
    belongs_to :memory_product, PcZone.Product
    field :memory_price, :integer
    field :memory_quantity, :integer
    field :memory_amount, :integer
    belongs_to :hard_drive, PcZone.HardDrive
    belongs_to :hard_drive_product, PcZone.Product
    field :hard_drive_price, :integer
    field :hard_drive_quantity, :integer
    field :hard_drive_amount, :integer
    field :option_values, {:array, :string}
    field :total, :integer
    field :config, :map
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
