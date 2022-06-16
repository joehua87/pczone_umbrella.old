defmodule PcZone.Memories do
  import Ecto.Query, only: [from: 2]
  alias PcZone.Repo

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
    |> PcZone.Helpers.ensure_slug()
    |> PcZone.Memory.new_changeset()
    |> PcZone.Helpers.get_changeset_changes()
  end
end
