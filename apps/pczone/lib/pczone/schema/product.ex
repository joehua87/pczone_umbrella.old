defmodule Pczone.Product do
  use Pczone.Schema
  import Ecto.Changeset

  @required [
    :code,
    :name,
    :slug,
    :title,
    :condition,
    :sale_price,
    :percentage_off,
    :component_type,
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
    field :name, :string
    field :title, :string
    field :condition, :string
    field :component_type, Ecto.Enum, values: Pczone.Enum.product_component_types()
    field :is_bundled, :boolean
    field :list_price, :integer
    field :sale_price, :integer
    field :percentage_off, :decimal
    field :cost, :integer
    field :stock, :integer, default: 0
    embeds_many :media, Pczone.EmbeddedMedium, on_replace: :delete
    belongs_to :post, Pczone.Post
    has_one :component_product, Pczone.ComponentProduct
    many_to_many :taxons, Pczone.Taxon, join_through: Pczone.ProductTaxon
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:media)
  end

  def new_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
