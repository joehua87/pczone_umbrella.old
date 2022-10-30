defmodule Pczone.Taxon do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:name, :path, :taxonomy_id]
  @optional [:description, :translation]

  schema "taxon" do
    field :name, :string
    field :path, EctoLtree.LabelTree
    field :description, :string
    field :translation, {:map, :string}
    belongs_to :taxonomy, Pczone.Taxonomy
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
