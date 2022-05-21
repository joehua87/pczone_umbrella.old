defmodule Xeon.BuiltPsu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_id, :psu_id, :product_id, :quantity]
  @optional []

  schema "built_psu" do
    belongs_to :built, Xeon.Built
    belongs_to :psu, Xeon.Psu
    belongs_to :product, Xeon.Product
    field :quantity, :integer
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
