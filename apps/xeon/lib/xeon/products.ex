defmodule Xeon.Products do
  require Logger
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  alias Xeon.{Repo, Product}

  def get(id) do
    Repo.get(Product, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Product
    |> where(^parse_filter(filter))
    |> select_fields(selection)
    |> sort_by(order_by, ["title"])
    |> IO.inspect(label: "TTT")
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create(params) do
    params |> Product.new_changeset() |> Repo.insert()
  end

  def update(%{id: id} = params) do
    params = Enum.filter(params, fn {_key, value} -> value != nil end) |> Enum.into(%{})
    get(id) |> Product.changeset(params) |> Repo.update()
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
