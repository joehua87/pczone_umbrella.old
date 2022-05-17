defmodule Xeon.Psu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :form_factor]
  @optional [:brand_id]

  schema "psu" do
    field :name, :string
    field :form_factor, :string
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
