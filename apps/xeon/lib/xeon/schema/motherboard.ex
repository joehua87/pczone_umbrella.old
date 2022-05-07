defmodule Xeon.Motherboard do
  use Ecto.Schema

  schema "motherboard" do
    field :name, :string
    field :max_memory_capacity, :integer
    field :memory_types, {:array, :string}
    field :memory_slots, :integer
    field :processor_slots, :integer, default: 1
    belongs_to :chipset, Xeon.Chipset
    field :socket, :string
    field :note, :string
  end
end
