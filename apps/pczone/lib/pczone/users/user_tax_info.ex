defmodule Pczone.UserTaxInfo do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:user_id]
  @optional []

  schema "user_tax_info" do
    belongs_to :user, Pczone.Users.User
    embeds_one :tax_info, Pczone.TaxInfo, on_replace: :update
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:tax_info)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
