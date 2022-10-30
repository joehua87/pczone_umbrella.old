defmodule Pczone.BuiltExtensionDevice do
  use Pczone.Schema
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
    belongs_to :built, Pczone.Built
    belongs_to :extension_device, Pczone.ExtensionDevice
    belongs_to :product, Pczone.Product
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
