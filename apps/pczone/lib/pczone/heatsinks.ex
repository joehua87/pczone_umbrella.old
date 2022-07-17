defmodule Pczone.Heatsinks do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.Repo

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(Pczone.Heatsink, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Heatsink
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def get_map_by_slug() do
    Repo.all(from c in Pczone.Heatsink, select: {c.slug, c.id}) |> Enum.into(%{})
  end

  def upsert(entities, opts \\ []) do
    brands_map = Pczone.Brands.get_map_by_slug()

    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(
             entities,
             &parse_entity_for_upsert(&1, brands_map: brands_map)
           ) do
      Repo.insert_all_2(
        Pczone.Heatsink,
        list,
        Keyword.merge(opts,
          on_conflict: {:replace, [:code, :name, :supported_types, :brand_id]},
          conflict_target: [:slug]
        )
      )
    end
  end

  def parse_entity_for_upsert(params, brands_map: brands_map) do
    case params do
      %{brand: brand} ->
        Map.put(params, :brand_id, brands_map[brand])

      %{"brand" => brand} ->
        Map.put(params, "brand_id", brands_map[brand])
    end
    |> Pczone.Helpers.ensure_slug()
    |> Pczone.Heatsink.new_changeset()
    |> Pczone.Helpers.get_changeset_changes()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        :brand_id -> parse_id_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
