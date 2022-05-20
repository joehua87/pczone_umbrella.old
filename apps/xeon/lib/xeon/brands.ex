defmodule Xeon.Brands do
  alias Xeon.{Repo, Brand}

  def upsert(entities, opts \\ []) do
    entities =
      Enum.map(entities, fn entity ->
        Xeon.Brand.new_changeset(entity) |> Xeon.Helpers.get_changeset_changes()
      end)

    Repo.insert_all(
      Brand,
      entities,
      Keyword.merge(opts, on_conflict: :replace_all, conflict_target: [:name])
    )
  end
end
