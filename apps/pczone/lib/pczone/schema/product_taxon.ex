defmodule Pczone.ProductTaxon do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:product_id, :taxonomy_id, :taxon_id]
  @optional []

  schema "product_taxon" do
    belongs_to :product, Pczone.Product
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
