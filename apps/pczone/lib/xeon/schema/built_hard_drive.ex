defmodule PcZone.BuiltHardDrive do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :hard_drive_id,
    :product_id,
    :slot_type,
    :processor_index,
    :price,
    :quantity,
    :total
  ]
  @optional [:extension_device_id]

  schema "built_hard_drive" do
    belongs_to :built, PcZone.Built
    belongs_to :hard_drive, PcZone.HardDrive
    belongs_to :product, PcZone.Product
    belongs_to :extension_device, PcZone.ExtensionDevice
    field :slot_type, :string
    field :processor_index, :integer
    field :price, :integer
    field :quantity, :integer
    field :total, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
