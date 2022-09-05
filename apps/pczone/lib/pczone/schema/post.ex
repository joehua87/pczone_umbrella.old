defmodule Pczone.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:title]
  @optional [:description, :md, :state]

  schema "post" do
    field :title, :string
    field :description, :string
    field :md, :string
    field :state, :string
    embeds_one :seo, Pczone.Seo
    embeds_many :media, Pczone.EmbeddedMedium
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:seo)
    |> cast_embed(:media)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
