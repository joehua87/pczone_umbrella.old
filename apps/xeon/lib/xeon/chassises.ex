defmodule Xeon.Chassises do
  import Ecto.Query, only: [from: 2]
  alias Xeon.Repo

  def get_map_by_slug() do
    Repo.all(from c in Xeon.Chassis, select: {c.slug, c.id}) |> Enum.into(%{})
  end

  def upsert(entities, opts \\ []) do
    brands_map = Xeon.Brands.get_map_by_slug()
    entities = Enum.map(entities, &parse_entity_for_upsert(&1, brands_map: brands_map))

    Repo.insert_all(
      Xeon.Chassis,
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
    |> Xeon.Chassis.new_changeset()
    |> Xeon.Helpers.get_changeset_changes()
  end
end
