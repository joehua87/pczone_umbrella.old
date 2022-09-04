defmodule Pczone.Taxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:code, :name]
  @optional [:description]

  schema "taxonomy" do
    field :code, :string
    field :name, :string
    field :description, :string
    has_many :taxons, Pczone.Taxon
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
