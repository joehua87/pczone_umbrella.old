defmodule Pczone.StockMovementItem do
  use Pczone.Schema
  import Ecto.Changeset

  @required [
    :code,
    :product_id,
    :stock_movement_id,
    :source_location,
    :destination_location,
    :quantity
  ]
  @optional []

  schema "stock_movement_item" do
    field :code, :string
    belongs_to :product, Pczone.Product
    belongs_to :stock_movement, Pczone.StockMovement
    field :source_location, :string
    field :destination_location, :string
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    # product_id = Map.get(params, :product_id)
    # code = Map.get(params, :code)
    # key = "#{product_id}:#{code}"
    changeset(%__MODULE__{}, params)
  end
end
