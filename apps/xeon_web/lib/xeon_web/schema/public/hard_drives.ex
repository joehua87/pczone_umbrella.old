defmodule XeonWeb.Schema.HardDrives do
  use Absinthe.Schema.Notation

  object :hard_drive do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end
end
