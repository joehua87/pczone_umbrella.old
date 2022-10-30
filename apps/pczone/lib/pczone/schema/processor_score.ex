defmodule Pczone.ProcessorScore do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:processor_id, :test_name, :single, :multi]
  @optional []

  schema "processor_score" do
    belongs_to :processor, Pczone.Processor
    field :test_name, :string
    field :single, :integer
    field :multi, :integer
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
