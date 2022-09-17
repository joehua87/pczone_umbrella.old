defmodule Pczone.BuiltCooler do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :cooler_id,
    :product_id,
    :quantity
  ]
  @optional []

  schema "built_cooler" do
    belongs_to :built, Pczone.Built
    belongs_to :cooler, Pczone.Cooler
    belongs_to :product, Pczone.Product
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
