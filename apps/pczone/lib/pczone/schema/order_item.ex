defmodule Pczone.OrderItem do
  use Pczone.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  @required [:order_id, :product_name, :quantity, :price, :amount]
  @optional [:product_id]

  schema "order_item" do
    belongs_to :order, Pczone.Order
    belongs_to :product, Pczone.Product
    field :product_name, :string
    embeds_one :image, Pczone.EmbeddedMedium
    field :from_built, :boolean, default: false
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
