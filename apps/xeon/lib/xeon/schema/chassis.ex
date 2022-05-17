defmodule Xeon.Chassis do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :form_factor, :psu_form_factors]
  @optional [:brand_id]

  schema "chassis" do
    field :name, :string
    field :form_factor, :string
    field :psu_form_factors, {:array, :string}, default: []
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
