defmodule Xeon.Processor do
  use Ecto.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  @required [
    :code,
    :slug,
    :name,
    :sub,
    :code_name,
    :collection_name,
    :launch_date,
    :status,
    :vertical_segment,
    :cache_size,
    :cores,
    :url,
    :memory_types
  ]

  @optional [
    :socket,
    :case_temperature,
    :lithography,
    :base_frequency,
    :tdp_up_base_frequency,
    :tdp_down_base_frequency,
    :max_turbo_frequency,
    :tdp,
    :tdp_up,
    :tdp_down,
    :threads,
    :processor_graphics,
    :gpu_id,
    :memory_types,
    :ecc_memory_supported
  ]

  schema "processor" do
    field :code, :string
    field :slug, :string
    field :name, :string
    field :sub, :string
    field :code_name, :string
    belongs_to :gpu, Xeon.Gpu
    field :collection_name, :string
    field :launch_date, :string
    field :vertical_segment, :string
    field :status, :string
    field :socket, :string
    field :case_temperature, :decimal
    field :lithography, :string
    field :base_frequency, :decimal
    field :tdp_up_base_frequency, :decimal
    field :tdp_down_base_frequency, :decimal
    field :max_turbo_frequency, :decimal
    field :tdp, :decimal
    field :tdp_up, :decimal
    field :tdp_down, :decimal
    field :cache_size, :decimal
    field :cores, :integer
    field :threads, :integer
    field :processor_graphics, :string
    field :url, :string
    field :meta, :map, default: %{}
    field :memory_types, {:array, :string}
    field :ecc_memory_supported, :boolean
    embeds_many :attributes, Xeon.AttributeGroup
    has_many :products, Xeon.Product
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> cast_embed(:attributes)
    |> validate_required(@required)
  end

  def new_changeset(params) do
    changeset(%__MODULE__{}, params)
    |> validate_required(@required)
  end
end
