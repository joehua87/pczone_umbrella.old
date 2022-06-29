defmodule PcZone.Memories do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias PcZone.Repo

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(PcZone.Memory, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    PcZone.Memory
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def get_by_code(code) do
    Repo.one(from x in PcZone.Memory, where: x.code == ^code, limit: 1)
  end

  def upsert(entities, opts \\ []) do
    brands_map = PcZone.Brands.get_map_by_slug()
    entities = Enum.map(entities, &parse_entity_for_upsert(&1, brands_map: brands_map))

    Repo.insert_all(
      PcZone.Memory,
      entities,
      Keyword.merge(opts,
        on_conflict: {:replace, [:slug, :code, :name, :capacity, :type, :brand_id, :description]},
        conflict_target: [:slug]
      )
    )
  end

  def parse_entity_for_upsert(params, brands_map: brands_map) do
    case params do
      %{brand: brand} ->
        Map.put(params, :brand_id, brands_map[brand])

      %{"brand" => brand} ->
        Map.put(params, "brand_id", brands_map[brand])
    end
    |> PcZone.Helpers.ensure_slug()
    |> PcZone.Memory.new_changeset()
    |> PcZone.Helpers.get_changeset_changes()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :code -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        :type -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
