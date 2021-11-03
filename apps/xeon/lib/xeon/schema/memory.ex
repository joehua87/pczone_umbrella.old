defmodule Xeon.Memory do
  use Ecto.Schema

  schema "memory" do
    field :name, :string
    belongs_to :memory_type, Xeon.MemoryType
  end
end
