defmodule Xeon.MemoryType do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name]
  @optional []

  schema "memory_type" do
    field :name, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
