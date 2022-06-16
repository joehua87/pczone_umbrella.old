defmodule PcZone.SimpleBuildProcessor do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:simple_build_id, :processor_id, :processor_product_id]
  @optional [:gpu_id, :gpu_product_id]

  schema "simple_build_processor" do
    belongs_to :simple_build, PcZone.SimpleBuild
    belongs_to :processor, PcZone.Processor
    belongs_to :processor_product, PcZone.Product
    belongs_to :gpu, PcZone.Gpu
    belongs_to :gpu_product, PcZone.Product
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
