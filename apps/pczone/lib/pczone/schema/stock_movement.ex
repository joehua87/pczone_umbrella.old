defmodule Pczone.StockMovement do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:state]
  @optional [:submitted_at]

  schema "stock_movement" do
    field :submitted_at, :utc_datetime
    field :state, Ecto.Enum, values: [:created, :submitted, :canceled], default: :created
    has_many :items, Pczone.StockMovementItem
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
