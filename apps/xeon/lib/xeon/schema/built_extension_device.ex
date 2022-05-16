defmodule Xeon.BuiltExtensionDevice do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_id, :extension_device_id, :product_id, :quantity]
  @optional []

  schema "built_extension_device" do
    belongs_to :built, Xeon.Built
    belongs_to :extension_device, Xeon.ExtensionDevice
    belongs_to :product, Xeon.Product
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
