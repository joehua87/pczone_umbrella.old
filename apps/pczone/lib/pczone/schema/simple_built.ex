defmodule Pczone.SimpleBuilt do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:code, :name, :option_types, :barebone_id, :barebone_product_id]
  @optional [:option_value_seperator, :body_template]

  schema "simple_built" do
    field :code, :string, null: false
    field :name, :string, null: false
    embeds_many :media, Pczone.EmbeddedMedium
    field :body_template, :string, null: false
    field :option_types, {:array, :string}, null: false
    field :option_value_seperator, :string, null: false, default: ", "
    belongs_to :barebone, Pczone.Barebone
    belongs_to :barebone_product, Pczone.Product
    has_many :processors, Pczone.SimpleBuiltProcessor
    has_many :memories, Pczone.SimpleBuiltMemory
    has_many :hard_drives, Pczone.SimpleBuiltHardDrive
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
