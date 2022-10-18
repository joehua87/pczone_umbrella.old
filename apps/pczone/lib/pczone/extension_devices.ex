defmodule Pczone.ExtensionDevices do
  import Ecto.Query, only: [from: 2]
  alias Pczone.Repo

  def get_map_by_slug() do
    Repo.all(from c in Pczone.ExtensionDevice, select: {c.slug, c.id}) |> Enum.into(%{})
  end

  def upsert(entities, opts \\ []) do
    brands_map = Pczone.Brands.get_map_by_slug()

    with list when is_list(list) <-
           Pczone.Helpers.get_list_changset_changes(
             entities,
             &parse_entity_for_upsert(&1, brands_map: brands_map)
           ) do
      Repo.insert_all_2(
        Pczone.ExtensionDevice,
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
    |> Pczone.Helpers.ensure_slug()
    |> Pczone.ExtensionDevice.new_changeset()
    |> Pczone.Helpers.get_changeset_changes()
  end
end
