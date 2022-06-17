defmodule PcZone.SimpleBuildHardDrive do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:simple_build_id, :hard_drive_id, :hard_drive_product_id]
  @optional [:quantity]

  schema "simple_build_hard_drive" do
    belongs_to :simple_build, PcZone.SimpleBuild
    belongs_to :hard_drive, PcZone.HardDrive
    belongs_to :hard_drive_product, PcZone.Product
    field :quantity, :integer, default: 1
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
