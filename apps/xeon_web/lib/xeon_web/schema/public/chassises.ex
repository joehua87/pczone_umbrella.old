defmodule XeonWeb.Schema.Chassises do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :chassis do
    field :id, non_null(:id)
    field :name, non_null(:string)

    field :brand,
          :brand,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)
  end
end
