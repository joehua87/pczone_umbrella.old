defmodule PcZone.Brands do
  import Ecto.Query, only: [from: 2]
  alias PcZone.{Repo, Brand}

  def upsert(entities, opts \\ []) do
    entities =
      Enum.map(entities, fn entity ->
        PcZone.Brand.new_changeset(entity) |> PcZone.Helpers.get_changeset_changes()
      end)

    Repo.insert_all(
      Brand,
      entities,
      Keyword.merge(opts, on_conflict: :replace_all, conflict_target: [:slug])
    )
  end

  def get_map_by_slug() do
    Repo.all(from c in Brand, select: {c.slug, c.id}) |> Enum.into(%{})
  end
end
