defmodule Pczone.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @product_types [:barebone, :motherboard, :processor, :memory, :gpu, :hard_drive, :psu, :chassis]

  @required [:sku, :slug, :title, :condition, :sale_price, :percentage_off]
  @optional [
    :type,
    :stock,
    :list_price,
    :cost,
    :category_id,
    :barebone_id,
    :motherboard_id,
    :processor_id,
    :memory_id,
    :gpu_id,
    :hard_drive_id,
    :psu_id,
    :chassis_id,
    :heatsink_id
  ]

  schema "product" do
    field :sku, :string
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :integer
    field :sale_price, :integer
    field :percentage_off, :decimal
    field :cost, :integer
    field :stock, :integer, default: 0
    field :type, Ecto.Enum, values: @product_types
    belongs_to :category, Pczone.ProductCategory
    belongs_to :barebone, Pczone.Barebone
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :processor, Pczone.Processor
    belongs_to :memory, Pczone.Memory
    belongs_to :gpu, Pczone.Gpu
    belongs_to :hard_drive, Pczone.HardDrive
    belongs_to :psu, Pczone.Psu
    belongs_to :chassis, Pczone.Chassis
    belongs_to :heatsink, Pczone.Heatsink
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
