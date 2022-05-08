defmodule XeonWeb.Schema.Products do
  use Absinthe.Schema.Notation

  object :product do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :condition, non_null(:string)
    field :list_price, non_null(:decimal)
    field :sale_price, non_null(:decimal)
  end
end
