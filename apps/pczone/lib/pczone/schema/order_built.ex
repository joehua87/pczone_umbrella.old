defmodule Pczone.OrderBuilt do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:order_id, :built_template_name, :quantity, :price, :amount]
  @optional [:built_id]

  schema "order_built" do
    belongs_to :order, Pczone.Order
    belongs_to :built, Pczone.Built
    field :built_template_name, :string
    embeds_one :image, Pczone.EmbeddedMedium
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
