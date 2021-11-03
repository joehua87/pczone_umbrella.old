defmodule Xeon.ProcessorFamily do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name]
  @optional []

  schema "processor_family" do
    field :name, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
