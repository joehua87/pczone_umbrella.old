defmodule Pczone.OrderBuilt do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:order_id, :built_id, :quantity, :price, :amount]
  @optional []

  schema "order_built" do
    belongs_to :order, Pczone.Order
    belongs_to :built, Pczone.Built
    field :price, :integer
    field :quantity, :integer
    field :amount, :integer
    timestamps()
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
