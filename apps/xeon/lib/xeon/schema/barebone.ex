defmodule Xeon.Barebone do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :motherboard_id, :chassis_id, :psu_id]
  @optional [:brand_id]

  schema "barebone" do
    field :name, :string
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :chassis, Xeon.Chassis
    belongs_to :psu, Xeon.Psu
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
