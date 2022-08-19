defmodule Pczone.BuiltTemplateVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [
    :name,
    :built_template_id,
    :barebone_id,
    :barebone_product_id,
    :barebone_price,
    :processor_id,
    :processor_product_id,
    :processor_price,
    :processor_quantity,
    :processor_amount,
    :option_values,
    :position,
    :total,
    :config
  ]

  @optional [
    :memory_id,
    :memory_product_id,
    :memory_price,
    :memory_quantity,
    :memory_amount,
    :hard_drive_id,
    :hard_drive_product_id,
    :hard_drive_price,
    :hard_drive_quantity,
    :hard_drive_amount,
    :gpu_id,
    :gpu_product_id,
    :gpu_price,
    :gpu_quantity,
    :gpu_amount,
    :image_id,
    :state
  ]

  schema "built_template_variant" do
    field :name, :string
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :barebone, Pczone.Barebone
    belongs_to :barebone_product, Pczone.Product
    field :barebone_price, :integer
    belongs_to :processor, Pczone.Processor
    belongs_to :processor_product, Pczone.Product
    field :processor_price, :integer
    field :processor_quantity, :integer
    field :processor_amount, :integer
    belongs_to :gpu, Pczone.Gpu
    belongs_to :gpu_product, Pczone.Product
    field :gpu_price, :integer
    field :gpu_quantity, :integer
    field :gpu_amount, :integer
    belongs_to :memory, Pczone.Memory
    belongs_to :memory_product, Pczone.Product
    field :memory_price, :integer
    field :memory_quantity, :integer
    field :memory_amount, :integer
    belongs_to :hard_drive, Pczone.HardDrive
    belongs_to :hard_drive_product, Pczone.Product
    field :hard_drive_price, :integer
    field :hard_drive_quantity, :integer
    field :hard_drive_amount, :integer
    field :image_id, :string
    field :option_values, {:array, :string}
    field :position, :integer
    field :total, :integer
    field :state, Ecto.Enum, values: [:active, :disabled], default: :active
    field :config, :map
    has_many :stores, Pczone.BuiltTemplateVariantStore
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
