defmodule PcZone.ExtensionDevices do
  import Ecto.Query, only: [from: 2]
  alias PcZone.Repo

  def get_map_by_slug() do
    Repo.all(from c in PcZone.ExtensionDevice, select: {c.slug, c.id}) |> Enum.into(%{})
  end

  def upsert(entities, opts \\ []) do
    brands_map = PcZone.Brands.get_map_by_slug()

    with list = [_ | _] <-
           PcZone.Helpers.get_list_changset_changes(
             entities,
             &parse_entity_for_upsert(&1, brands_map: brands_map)
           ) do
      Repo.insert_all_2(
        PcZone.ExtensionDevice,
        list,
        Keyword.merge(opts,
          on_conflict: :replace_all,
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
    |> PcZone.Helpers.ensure_slug()
    |> PcZone.ExtensionDevice.new_changeset()
    |> PcZone.Helpers.get_changeset_changes()
  end
end
