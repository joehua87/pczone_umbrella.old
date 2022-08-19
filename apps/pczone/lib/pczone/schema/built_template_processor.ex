defmodule Pczone.BuiltTemplateProcessor do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:key, :built_template_id, :processor_id, :processor_product_id]
  @optional [
    :processor_quantity,
    :processor_label,
    :gpu_id,
    :gpu_product_id,
    :gpu_quantity,
    :gpu_label
  ]

  schema "built_template_processor" do
    field :key, :string
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :processor, Pczone.Processor
    belongs_to :processor_product, Pczone.Product
    field :processor_quantity, :integer, default: 1
    field :processor_label, :string
    belongs_to :gpu, Pczone.Gpu
    belongs_to :gpu_product, Pczone.Product
    field :gpu_quantity, :integer, default: 1
    field :gpu_label, :string
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
