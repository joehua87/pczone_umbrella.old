defmodule Pczone.ChipsetProcessor do
  use Pczone.Schema

  schema "chipset_processor" do
    belongs_to :processor, Pczone.Processor
    belongs_to :chipset, Pczone.Chipset
  end
end
