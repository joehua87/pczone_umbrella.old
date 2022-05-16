defmodule Xeon.BuiltHardDrive do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_id, :hard_drive_id, :product_id, :slot, :quantity]
  @optional [:extension_device_id]

  schema "built_hard_drive" do
    belongs_to :built, Xeon.Built
    belongs_to :hard_drive, Xeon.HardDrive
    belongs_to :product, Xeon.Product
    belongs_to :extension_device, Xeon.ExtensionDevice
    field :slot, :string
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
