defmodule Pczone.AttributeItems do
  # import Ecto.Query, only: [from: 2]
  alias Pczone.Repo

  @doc """
  Upsert a list of attributes
  """
  def upsert(list, attributes_map \\ nil) do
    attribute_codes = list |> Enum.map(& &1["code"]) |> Enum.uniq()
    attributes_map = attributes_map || Pczone.Attributes.get_map_by_code(attribute_codes)

    list =
      list
      |> Enum.filter(fn item ->
        Map.get(item, "path") not in ["", nil]
      end)
      |> Enum.map(fn %{"attribute" => attribute_code, "path" => path} ->
        path_items = path |> String.split(" / ") |> Enum.map(&String.trim/1)

        %{
          attribute_id: attributes_map[attribute_code].id,
          name: List.last(path_items),
          path: %EctoLtree.LabelTree{labels: Enum.map(path_items, &Recase.to_snake/1)}
        }
      end)

    Repo.insert_all_2(Pczone.AttributeItem, list,
      on_conflict: {:replace, [:name, :description, :translation]},
      conflict_target: [:attribute_id, :path]
    )
  end
end
