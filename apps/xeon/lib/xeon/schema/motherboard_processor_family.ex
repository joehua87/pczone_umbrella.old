defmodule Xeon.MotherboardProcessorCollection do
  use Ecto.Schema

  schema "motherboard_processor_collection" do
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :processor_collection, Xeon.ProcessorCollection
  end
end
