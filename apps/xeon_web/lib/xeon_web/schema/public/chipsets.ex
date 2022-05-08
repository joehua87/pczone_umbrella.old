defmodule XeonWeb.Schema.Chipsets do
  use Absinthe.Schema.Notation

  object :chipset do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :processors, non_null(list_of(non_null(:processor)))
  end
end
