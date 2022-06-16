defmodule PcZone.BuiltPsu do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :built_id,
    :psu_id,
    :product_id,
    :price,
    :quantity,
    :total
  ]
  @optional []

  schema "built_psu" do
    belongs_to :built, PcZone.Built
    belongs_to :psu, PcZone.Psu
    belongs_to :product, PcZone.Product
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
