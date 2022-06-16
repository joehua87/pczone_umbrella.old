defmodule PcZone.BuiltProcessor do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :processor_id,
    :product_id,
    :price,
    :quantity,
    :total
  ]
  @optional [:extension_device_id]

  schema "built_processor" do
    belongs_to :built, PcZone.Built
    belongs_to :processor, PcZone.Processor
    belongs_to :product, PcZone.Product
    belongs_to :extension_device, PcZone.ExtensionDevice
    field :price, :integer
    field :quantity, :integer
    field :total, :integer
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
