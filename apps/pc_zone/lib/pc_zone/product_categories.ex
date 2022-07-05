defmodule PcZone.ProductCategories do
  require Logger
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  alias PcZone.{Repo, ProductCategory}

  def get(id) do
    Repo.get(ProductCategory, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    ProductCategory
    |> where(^parse_filter(filter))
    |> select_fields(selection)
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create(params) do
    params |> ProductCategory.new_changeset() |> Repo.insert()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :title -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
