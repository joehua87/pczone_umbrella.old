defmodule Xeon.BuiltGpu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_id, :gpu_id, :product_id, :quantity]
  @optional []

  schema "built_gpu" do
    belongs_to :built, Xeon.Built
    belongs_to :gpu, Xeon.Gpu
    belongs_to :product, Xeon.Product
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
