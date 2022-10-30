defmodule Pczone.Order do
  use Pczone.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  @required [:code, :token]
  @optional [:user_id, :customer_id, :state, :total]

  schema "order" do
    field :code, :string
    belongs_to :user, Pczone.Users.User
    belongs_to :customer, Pczone.Customer
    embeds_one :shipping_address, Pczone.Address
    embeds_one :tax_info, Pczone.TaxInfo
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
    |> cast_embed(:shipping_address)
    |> cast_embed(:tax_info)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
