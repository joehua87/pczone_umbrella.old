defmodule Pczone.StoreProduct do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:product_code, :name]
  @optional [:description, :sold, :stats, :created_at]

  schema "store_product" do
    belongs_to :store, Pczone.Store
    field :product_code, :string
    field :name, :string
    field :description, :string
    belongs_to :product, Pczone.Product
    belongs_to :built_template, Pczone.BuiltTemplate
    embeds_many :options, Pczone.ProductOption, on_replace: :delete
    embeds_many :images, Pczone.EmbeddedMedium, on_replace: :delete
    field :sold, :integer
    field :stats, {:map, :integer}, default: %{}
    field :created_at, :utc_datetime
    has_many :variants, Pczone.StoreVariant
    timestamps()
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:images)
    |> cast_embed(:options)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
