defmodule Pczone.BuiltTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:code, :name, :option_types, :barebone_id, :barebone_product_id]
  @optional [:option_value_seperator, :body_template]

  schema "built_template" do
    field :code, :string
    field :name, :string
    embeds_many :media, Pczone.EmbeddedMedium
    field :body_template, :string
    field :option_types, {:array, :string}
    field :option_value_seperator, :string, default: ", "
    belongs_to :barebone, Pczone.Barebone
    belongs_to :barebone_product, Pczone.Product
    has_many :processors, Pczone.BuiltTemplateProcessor
    has_many :memories, Pczone.BuiltTemplateMemory
    has_many :hard_drives, Pczone.BuiltTemplateHardDrive
    has_many :builts, Pczone.Built
    has_many :built_template_stores, Pczone.BuiltTemplateStore
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