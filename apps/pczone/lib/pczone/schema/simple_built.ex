defmodule Pczone.SimpleBuilt do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:code, :name, :option_types, :barebone_id, :barebone_product_id]
  @optional [:option_value_seperator, :body_template]

  schema "simple_built" do
    field :code, :string
    field :name, :string
    embeds_many :media, Pczone.EmbeddedMedium
    field :body_template, :string
    field :option_types, {:array, :string}
    field :option_value_seperator, :string, default: ", "
    belongs_to :barebone, Pczone.Barebone
    belongs_to :barebone_product, Pczone.Product
    has_many :processors, Pczone.SimpleBuiltProcessor
    has_many :memories, Pczone.SimpleBuiltMemory
    has_many :hard_drives, Pczone.SimpleBuiltHardDrive
    has_many :variants, Pczone.SimpleBuiltVariant
    has_many :simple_built_stores, Pczone.SimpleBuiltStore
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> cast_embed(:media)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
  end
end
