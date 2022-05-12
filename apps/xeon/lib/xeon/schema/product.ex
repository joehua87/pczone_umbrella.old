defmodule Xeon.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @product_types [:barebone, :motherboard, :processor, :memory, :gpu, :hard_drive, :psu, :chassis]

  @required [:slug, :title, :condition, :list_price, :sale_price]
  @optional [
    :type,
    :stock,
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
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :integer
    field :sale_price, :integer
    field :percentage_off, :decimal
    field :stock, :integer, default: 0
    field :type, Ecto.Enum, values: @product_types
    belongs_to :category, Xeon.ProductCategory
    belongs_to :barebone, Xeon.Barebone
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :processor, Xeon.Processor
    belongs_to :memory, Xeon.Memory
    belongs_to :gpu, Xeon.Gpu
    belongs_to :hard_drive, Xeon.HardDrive
    belongs_to :psu, Xeon.Psu
    belongs_to :chassis, Xeon.Chassis
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
