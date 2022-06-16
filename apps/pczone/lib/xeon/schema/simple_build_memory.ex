defmodule PcZone.SimpleBuildMemory do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [:simple_build_id, :memory_id, :memory_product_id]
  @optional []

  schema "simple_build_memory" do
    belongs_to :simple_build, PcZone.SimpleBuild
    belongs_to :memory, PcZone.Memory
    belongs_to :memory_product, PcZone.Product
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
