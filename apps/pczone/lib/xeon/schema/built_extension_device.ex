defmodule PcZone.BuiltExtensionDevice do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :extension_device_id,
    :product_id,
    :slot_type,
    :processor_index,
    :quantity
  ]
  @optional []

  schema "built_extension_device" do
    belongs_to :built, PcZone.Built
    belongs_to :extension_device, PcZone.ExtensionDevice
    belongs_to :product, PcZone.Product
    field :slot_type, :string
    field :processor_index, :integer
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end