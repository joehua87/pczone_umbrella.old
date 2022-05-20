defmodule Xeon.BuiltMemory do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :memory_id,
    :product_id,
    :slot_type,
    :processor_index,
    :quantity
  ]
  @optional [:extension_device_id]

  schema "built_memory" do
    belongs_to :built, Xeon.Built
    belongs_to :memory, Xeon.Memory
    belongs_to :product, Xeon.Product
    belongs_to :extension_device, Xeon.ExtensionDevice
    field :slot_type, :string
    field :processor_index, :string
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end