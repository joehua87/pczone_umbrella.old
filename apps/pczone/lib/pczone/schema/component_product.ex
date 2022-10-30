defmodule Pczone.ComponentProduct do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:product_id, :type]

  @optional [
    :barebone_id,
    :motherboard_id,
    :processor_id,
    :memory_id,
    :gpu_id,
    :hard_drive_id,
    :psu_id,
    :chassis_id,
    :cooler_id
  ]

  schema "component_product" do
    belongs_to :product, Pczone.Product
    field :type, Ecto.Enum, values: Pczone.Enum.product_component_types()
    belongs_to :barebone, Pczone.Barebone
    belongs_to :motherboard, Pczone.Motherboard
    belongs_to :processor, Pczone.Processor
    belongs_to :memory, Pczone.Memory
    belongs_to :gpu, Pczone.Gpu
    belongs_to :hard_drive, Pczone.HardDrive
    belongs_to :psu, Pczone.Psu
    belongs_to :chassis, Pczone.Chassis
    belongs_to :cooler, Pczone.Cooler
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

  def changes_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required -- [:product_id])
  end
end
