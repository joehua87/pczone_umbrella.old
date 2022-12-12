defmodule Pczone.Order do
  use Pczone.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  @required [:code, :token]
  @optional [
    :user_id,
    :customer_id,
    :state,
    :items_count,
    :builts_count,
    :items_quantity,
    :builts_quantity,
    :items_total,
    :builts_total,
    :total,
    :submitted_at,
    :submitted_by_id,
    :approved_at,
    :approved_by_id,
    :canceled_at,
    :canceled_by_id,
    :shipped_at,
    :completed_at
  ]
  @order_states [
    :cart,
    :submitted,
    :canceled,
    :approved,
    :processing,
    :shipping,
    :completed
  ]

  schema "order" do
    field :code, :string
    belongs_to :user, Pczone.Users.User
    belongs_to :customer, Pczone.Customer
    embeds_one :shipping_address, Pczone.Address
    embeds_one :tax_info, Pczone.TaxInfo
    field :state, Ecto.Enum, values: @order_states, default: :cart
    field :items_count, :integer, default: 0
    field :builts_count, :integer, default: 0
    field :items_quantity, :integer, default: 0
    field :builts_quantity, :integer, default: 0
    field :items_total, :integer, default: 0
    field :builts_total, :integer, default: 0
    field :total, :integer, default: 0
    field :token, :string
    field :submitted_at, :utc_datetime
    belongs_to :submitted_by, Pczone.Users.User
    field :approved_at, :utc_datetime
    belongs_to :approved_by, Pczone.Users.User
    field :canceled_at, :utc_datetime
    belongs_to :canceled_by, Pczone.Users.User
    field :shipped_at, :utc_datetime
    field :completed_at, :utc_datetime
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
