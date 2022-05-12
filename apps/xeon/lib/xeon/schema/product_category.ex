defmodule Xeon.ProductCategory do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:slug, :title, :path]
  @optional []

  schema "product_category" do
    field :slug, :string
    field :title, :string
    field :path, EctoLtree.LabelTree
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
