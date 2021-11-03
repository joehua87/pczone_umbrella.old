defmodule Xeon.Motherboard do
  use Ecto.Schema
  import Ecto.Changeset

  @required [:name, :memory_slot, :max_memory_capacity, :chipset_id]
  @optional [:processor_slot]

  schema "motherboard" do
    field :name, :string
    field :max_memory_capacity, :integer
    field :memory_slot, :integer
    field :processor_slot, :integer, default: 1
    belongs_to :chipset, Xeon.Chipset
  end

  def changeset(entity, params) do
    entity
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end
end
