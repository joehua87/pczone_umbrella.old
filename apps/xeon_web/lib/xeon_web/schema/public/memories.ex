defmodule XeonWeb.Schema.Memories do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :memory do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :type, non_null(:string)
    field :capacity, non_null(:integer)

    field :brand,
          :brand,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)
  end
end
