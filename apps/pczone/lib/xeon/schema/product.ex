defmodule PcZone.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @product_types [:barebone, :motherboard, :processor, :memory, :gpu, :hard_drive, :psu, :chassis]

  @required [:sku, :slug, :title, :condition, :sale_price, :percentage_off]
  @optional [
    :type,
    :stock,
    :list_price,
    :category_id,
    :barebone_id,
    :motherboard_id,
    :processor_id,
    :memory_id,
    :gpu_id,
    :hard_drive_id,
    :psu_id,
    :chassis_id
  ]

  schema "product" do
    field :sku, :string
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :integer
    field :sale_price, :integer
    field :percentage_off, :decimal
    field :stock, :integer, default: 0
    field :type, Ecto.Enum, values: @product_types
    belongs_to :category, PcZone.ProductCategory
    belongs_to :barebone, PcZone.Barebone
    belongs_to :motherboard, PcZone.Motherboard
    belongs_to :processor, PcZone.Processor
    belongs_to :memory, PcZone.Memory
    belongs_to :gpu, PcZone.Gpu
    belongs_to :hard_drive, PcZone.HardDrive
    belongs_to :psu, PcZone.Psu
    belongs_to :chassis, PcZone.Chassis
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
