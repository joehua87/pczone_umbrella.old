defmodule Xeon.Processor do
  use Ecto.Schema
  import Ecto.Changeset

  @required [
    :name
  ]

  @optional [
    :frequency,
    :maximum_frequency,
    :cores,
    :threads,
    :tdp,
    :family_code,
    :socket,
    :gpu,
    :links
  ]

  schema "processor" do
    field :code, :string
    field :name, :string
    field :sub, :string
    belongs_to :collection, Xeon.ProcessorCollection
    field :collection_name, :string
    field :launch_date, :string
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

    embeds_many :attributes, Attribute do
      field :title, :string

      embeds_many :items, AttributeItem do
        field :label, :string
        field :value, :string
      end
    end
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  def new(params) do
    changeset(%__MODULE__{}, params)
  end
end
