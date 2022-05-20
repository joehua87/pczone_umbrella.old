defmodule Xeon.Brands do
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Brand}

  def upsert(entities, opts \\ []) do
    entities =
      Enum.map(entities, fn entity ->
        Xeon.Brand.new_changeset(entity) |> Xeon.Helpers.get_changeset_changes()
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
