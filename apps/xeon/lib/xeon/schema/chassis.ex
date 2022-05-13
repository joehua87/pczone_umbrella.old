defmodule Xeon.Chassis do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name]
  @optional [:brand_id]

  schema "chassis" do
    field :name, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
