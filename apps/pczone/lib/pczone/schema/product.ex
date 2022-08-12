defmodule Pczone.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :code,
    :slug,
    :title,
    :condition,
    :sale_price,
    :percentage_off,
    :is_component,
    :is_bundled
  ]

  @optional [
    :sku,
    :stock,
    :list_price,
    :cost
  ]

  schema "product" do
    field :sku, :string
    field :code, :string
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :is_component, :boolean
    field :is_bundled, :boolean
    field :list_price, :integer
    field :sale_price, :integer
    field :percentage_off, :decimal
    field :cost, :integer
    field :stock, :integer, default: 0
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
