defmodule Pczone.BuiltTemplateHardDrive do
  use Pczone.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:built_template_id, :hard_drive_id, :hard_drive_product_id]
  @optional [:quantity, :label]

  schema "built_template_hard_drive" do
    belongs_to :built_template, Pczone.BuiltTemplate
    belongs_to :hard_drive, Pczone.HardDrive
    belongs_to :hard_drive_product, Pczone.Product
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
