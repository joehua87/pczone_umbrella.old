defmodule Xeon.Gpu do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:name, :type, :memory_capacity, :memory_type, :form_factors, :brand_id]
  @optional [:tdp]

  schema "gpu" do
    field :name, :string
    field :type, :string
    field :memory_capacity, :integer
    field :memory_type, :string
    field :form_factors, {:array, :string}
    field :tdp, :integer
    belongs_to :brand, Xeon.Brand
    has_many :products, Xeon.Product
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
