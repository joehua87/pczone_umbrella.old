defmodule Pczone.Brands do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.Repo

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(Pczone.Brand, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Brand
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(entities, opts \\ []) do
    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(entities, fn entity ->
             Pczone.Brand.new_changeset(entity) |> Pczone.Helpers.get_changeset_changes()
           end) do
      Repo.insert_all_2(
        Pczone.Brand,
        list,
        Keyword.merge(opts, on_conflict: {:replace, [:name]}, conflict_target: [:slug])
      )
    end
  end

  def get_map_by_slug() do
    Repo.all(from c in Pczone.Brand, select: {c.slug, c.id}) |> Enum.into(%{})
  end

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
