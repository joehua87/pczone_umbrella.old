defmodule Pczone.Taxons do
  # import Ecto.Query, only: [from: 2]
  alias Pczone.Repo

  def get(id) do
    Repo.get(Pczone.Taxon, id)
  end

  @doc """
  Upsert a list of taxonomies
  """
  def upsert(list, taxonomies_map \\ nil) do
    taxonomy_codes = list |> Enum.map(& &1["code"]) |> Enum.uniq()
    taxonomies_map = taxonomies_map || Pczone.Taxonomies.get_map_by_code(taxonomy_codes)

    list =
      list
      |> Enum.filter(fn item ->
        Map.get(item, "path") not in ["", nil]
      end)
      |> Enum.map(fn %{"taxonomy" => taxonomy_code, "path" => path} ->
        path_items = path |> String.split(" / ") |> Enum.map(&String.trim/1)

        %{
          taxonomy_id: taxonomies_map[taxonomy_code].id,
          name: List.last(path_items),
          path: %EctoLtree.LabelTree{labels: Enum.map(path_items, &Recase.to_snake/1)}
        }
      end)

    Repo.insert_all_2(Pczone.Taxon, list,
      on_conflict: {:replace, [:name, :description, :translation]},
      conflict_target: [:taxonomy_id, :path]
    )
  end
end
