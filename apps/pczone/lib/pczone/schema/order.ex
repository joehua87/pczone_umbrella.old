defmodule Pczone.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:code, :token]
  @optional [:user_id, :customer_id, :state, :total]

  schema "order" do
    field :code, :string
    belongs_to :user, Pczone.Users.User
    belongs_to :customer, Pczone.Customer
    field :billing_address, :map
    field :shipping_address, :map
    field :tax_info, :map
    field :state, Ecto.Enum, values: [:cart, :submitted, :approved, :cancel], default: :cart
    field :total, :integer, default: 0
    field :token, :string
    has_many :items, Pczone.OrderItem
    has_many :builts, Pczone.OrderBuilt
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
