defmodule Xeon.Motherboard do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :memory_slot, :max_memory_capacity, :chipset]
  @optional [:processor_slot]

  schema "motherboard" do
    field :name, :string
    field :max_memory_capacity, :integer
    field :memory_slot, :integer
    field :processor_slot, :integer, default: 1
    field :chipset, :string
    field :socket, :string
    field :note, :string
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
