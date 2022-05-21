defmodule Xeon.BuiltProcessor do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_id, :processor_id, :product_id, :quantity]
  @optional [:extension_device_id]

  schema "built_processor" do
    belongs_to :built, Xeon.Built
    belongs_to :processor, Xeon.Processor
    belongs_to :product, Xeon.Product
    belongs_to :extension_device, Xeon.ExtensionDevice
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
