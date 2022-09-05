defmodule Pczone.Chipset do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [
    :slug,
    :code,
    :code_name,
    :name,
    :launch_date,
    :collection_name,
    :vertical_segment,
    :status
  ]
  @optional []

  schema "chipset" do
    field :slug, :string
    field :code, :string
    field :code_name, :string
    field :name, :string
    field :launch_date, :string
    field :collection_name, :string
    field :vertical_segment, :string
    field :status, :string
    belongs_to :post, Pczone.Post
    embeds_many :attributes, Pczone.AttributeGroup
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> cast_embed(:attributes)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
