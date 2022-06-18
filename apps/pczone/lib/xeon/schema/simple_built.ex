defmodule PcZone.SimpleBuilt do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:code, :name, :option_types]
  @optional [:option_value_seperator]

  schema "simple_built" do
    field :code, :string, null: false
    field :name, :string, null: false
    field :option_types, {:array, :string}, null: false
    field :option_value_seperator, :string, null: false, default: " + "
    belongs_to :barebone, PcZone.Barebone
    belongs_to :barebone_product, PcZone.Product
    has_many :processors, PcZone.SimpleBuiltProcessor
    has_many :memories, PcZone.SimpleBuiltMemory
    has_many :hard_drives, PcZone.SimpleBuiltHardDrive
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
