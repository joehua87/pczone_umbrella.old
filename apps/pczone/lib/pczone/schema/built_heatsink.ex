defmodule Pczone.BuiltHeatsink do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :heatsink_id,
    :product_id,
    :price,
    :quantity,
    :total
  ]
  @optional []

  schema "built_heatsink" do
    belongs_to :built, Pczone.Built
    belongs_to :heatsink, Pczone.Heatsink
    belongs_to :product, Pczone.Product
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
