defmodule Xeon.MotherboardProcessorFamily do
  use Ecto.Schema

  schema "motherboard_processor_family" do
    belongs_to :motherboard, Xeon.Motherboard
    belongs_to :processor_family, Xeon.ProcessorFamily
  end
end
