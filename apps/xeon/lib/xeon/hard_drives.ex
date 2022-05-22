defmodule Xeon.HardDrives do
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias Xeon.Repo

  def get(id) do
    Repo.get(Xeon.HardDrive, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Xeon.HardDrive
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def get_by_code(code) do
    Repo.one(from x in Xeon.HardDrive, where: x.code == ^code, limit: 1)
  end

  def upsert(entities, opts \\ []) do
    brands_map = Xeon.Brands.get_map_by_slug()
    entities = Enum.map(entities, &parse_entity_for_upsert(&1, brands_map: brands_map))

    Repo.insert_all(
      Xeon.HardDrive,
      entities,
      Keyword.merge(opts,
        on_conflict: :replace_all,
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
    |> Xeon.Helpers.ensure_slug()
    |> Xeon.HardDrive.new_changeset()
    |> Xeon.Helpers.get_changeset_changes()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :name -> parse_string_filter(acc, field, value)
        :type -> parse_string_filter(acc, field, value)
        :form_factor -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
