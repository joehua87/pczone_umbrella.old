defmodule XeonWeb.Schema.Chassises do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :hard_drive_slot do
    field :form_factor, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :chassis do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :hard_drive_slots, non_null(list_of(non_null(:hard_drive_slot)))

    field :brand,
          :brand,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)
  end
end
