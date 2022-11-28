defmodule Pczone.Post do
  use Pczone.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:title]
  @optional [:type, :description, :md, :state]

  schema "post" do
    field :title, :string
    field :type, :string
    field :description, :string
    field :md, :string
    field :state, :string
    embeds_one :rich_text, Pczone.RichText, on_replace: :update
    embeds_one :seo, Pczone.Seo, on_replace: :update
    embeds_many :media, Pczone.EmbeddedMedium, on_replace: :delete
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:rich_text)
    |> cast_embed(:media)
    |> cast_embed(:seo)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
