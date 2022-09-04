defmodule Pczone.BuiltTemplateTaxon do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:built_template_id, :taxonomy_id, :taxon_id]
  @optional []

  schema "built_template_taxon" do
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :taxonomy, Pczone.Taxonomy
    belongs_to :taxon, Pczone.Taxon
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
