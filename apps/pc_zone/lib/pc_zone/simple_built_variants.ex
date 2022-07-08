defmodule PcZone.SimpleBuiltVariants do
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias PcZone.Repo

  def get(id) do
    Repo.get(PcZone.SimpleBuiltVariant, id)
  end

  def get_by_code(code) do
    Repo.one(from PcZone.SimpleBuiltVariant, where: [code: ^code], limit: 1)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    PcZone.SimpleBuiltVariant
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
