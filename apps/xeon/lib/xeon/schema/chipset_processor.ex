defmodule Xeon.ChipsetProcessor do
  use Ecto.Schema

  schema "chipset_processor" do
    belongs_to :processor, Xeon.Processor
    belongs_to :chipset, Xeon.Chipset
  end
end
