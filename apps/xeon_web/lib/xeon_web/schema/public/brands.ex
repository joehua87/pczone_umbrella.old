defmodule XeonWeb.Schema.Brands do
  use Absinthe.Schema.Notation

  object :brand do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end
end
