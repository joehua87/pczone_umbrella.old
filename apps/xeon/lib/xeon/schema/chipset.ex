defmodule Xeon.Chipset do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [
    :shortname,
    :code_name,
    :name,
    :launch_date,
    :collection_name,
    :vertical_segment,
    :status
  ]
  @optional []

  schema "chipset" do
    field :shortname, :string
    field :code_name, :string
    field :name, :string
    field :launch_date, :string
    field :collection_name, :string
    field :vertical_segment, :string
    field :status, :string
    embeds_many :attributes, Xeon.AttributeGroup
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
