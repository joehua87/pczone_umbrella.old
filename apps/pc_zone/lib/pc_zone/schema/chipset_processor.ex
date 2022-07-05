defmodule PcZone.ChipsetProcessor do
  use Ecto.Schema

  schema "chipset_processor" do
    belongs_to :processor, PcZone.Processor
    belongs_to :chipset, PcZone.Chipset
  end
end
