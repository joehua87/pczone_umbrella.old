defmodule Pczone.ProcessorCollection do
  use Pczone.Schema
  import Ecto.Changeset

  @required [:name, :code, :socket]
  @optional []

  schema "processor_collection" do
    field :name, :string
    field :code, :string
    field :socket, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
