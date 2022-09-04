defmodule Pczone.AttributeItem do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :path, :attribute_id]
  @optional [:description, :translation]

  schema "attribute_item" do
    field :name, :string
    field :path, EctoLtree.LabelTree
    field :description, :string
    field :translation, {:map, :string}
    belongs_to :attribute, Pczone.Attribute
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
