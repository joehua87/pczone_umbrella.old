defmodule Xeon.Psus do
  alias Xeon.Repo

  def upsert(entities, opts \\ []) do
    brands_map = Xeon.Brands.get_map_by_slug()
    entities = Enum.map(entities, &parse_entity_for_upsert(&1, brands_map: brands_map))

    Repo.insert_all(
      Xeon.Psu,
      entities,
      Keyword.merge(opts,
        on_conflict: :replace_all,
        conflict_target: [:name]
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
    |> Xeon.Psu.new_changeset()
    |> Xeon.Helpers.get_changeset_changes()
  end
end
