defmodule Xeon.Chipsets do
  import Xeon.Helpers
  alias Xeon.{Repo, Chipset}

  def import_chipsets() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")

    cursor =
      Mongo.find(conn, "IntelChipset", %{
        "attributes.0" => %{"$exists" => true},
        "processors.0" => %{"$exists" => true}
      })

    entities = Enum.map(cursor, &parse/1)
    Repo.insert_all(Chipset, entities, on_conflict: :replace_all, conflict_target: [:shortname])
  end

  def parse(%{"title" => name, "attributes" => attributes}) do
    result =
      extract_attributes(attributes, [
        %{
          key: :code_name,
          group: "Essentials",
          label: "Code Name",
          transform: &String.replace(&1, "Products formerly ", "")
        },
        %{key: :status, group: "Essentials", label: "Status"},
        %{key: :launch_date, group: "Essentials", label: "Launch Date"},
        %{key: :vertical_segment, group: "Essentials", label: "Vertical Segment"},
        %{key: :collection_name, group: "Essentials", label: "Product Collection"}
      ])

    result
    |> Map.merge(%{
      name: name,
      shortname: parse_shortname(name),
      attributes: parse_attributes(attributes)
    })
  end

  defp parse_shortname(name) do
    name
    |> String.replace("Intel® Communications", "")
    |> String.replace("Intel® ", "")
    |> String.replace(" Chipset", "")
  end
end
