defmodule Pczone.BuiltTemplateMemory do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:key, :built_template_id, :memory_id, :memory_product_id]
  @optional [:quantity, :label]

  schema "built_template_memory" do
    field :key, :string
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :memory, Pczone.Memory
    belongs_to :memory_product, Pczone.Product
    field :quantity, :integer, default: 1
    field :label, :string
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
