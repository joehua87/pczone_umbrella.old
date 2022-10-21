defmodule Pczone.UserAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:user_id]
  @optional []

  schema "user_address" do
    belongs_to :user, Pczone.Users.User
    embeds_one :address, Pczone.Address, on_replace: :update
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:address)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
