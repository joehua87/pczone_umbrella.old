defmodule Xeon.MotherboardMemoryType do
  use Ecto.Schema

  schema "motherboard_memory_type" do
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :memory_type, Xeon.MemoryType
  end
end
