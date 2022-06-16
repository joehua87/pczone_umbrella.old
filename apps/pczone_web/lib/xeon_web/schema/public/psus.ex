defmodule PcZoneWeb.Schema.Psus do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :psu do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)

    field :brand,
          :brand,
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end
end
