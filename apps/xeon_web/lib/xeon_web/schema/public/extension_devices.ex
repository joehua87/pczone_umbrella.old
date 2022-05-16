defmodule XeonWeb.Schema.ExtensionDevices do
  use Absinthe.Schema.Notation

  object :extension_device do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :memory_slots, non_null(list_of(non_null(:memory_slot)))
    field :processor_slots, non_null(list_of(non_null(:processor_slot)))
    field :sata_slots, non_null(list_of(non_null(:sata_slot)))
    field :m2_slots, non_null(list_of(non_null(:m2_slot)))
  end
end
