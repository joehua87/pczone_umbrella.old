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
    field :name, :string
    field :frequency, :integer
    field :maximum_frequency, :integer
    field :cores, :integer
    field :threads, :integer
    field :tdp, :integer
    field :gpu, :string
    field :family_code, :string
    field :socket, :string
    field :links, {:map, :string}, default: %{}
    field :meta, :map, default: %{}
    belongs_to :processor_family, Xeon.ProcessorFamily
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
