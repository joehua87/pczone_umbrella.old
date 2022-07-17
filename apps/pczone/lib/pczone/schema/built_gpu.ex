defmodule Pczone.BuiltGpu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :gpu_id,
    :product_id,
    :slot_type,
    :processor_index,
    :price,
    :quantity,
    :total
  ]
  @optional []

  schema "built_gpu" do
    belongs_to :built, Pczone.Built
    belongs_to :gpu, Pczone.Gpu
    belongs_to :product, Pczone.Product
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
