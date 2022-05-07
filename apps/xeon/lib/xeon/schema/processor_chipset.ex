defmodule Xeon.ProcessorChipset do
  use Ecto.Schema

  schema "processor_chipset" do
    belongs_to :processor, Xeon.Processor
    belongs_to :chipset, Xeon.Chipset
  end
end
