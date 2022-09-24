defmodule Pczone.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :phone]
  @optional [:labels, :user_id]

  schema "customer" do
    field :name, :string
    field :phone, :string
    field :tax_info, :map
    field :addresses, :map
    field :labels, :map
    belongs_to :user, Pczone.Users.User
    timestamps()
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:media)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
