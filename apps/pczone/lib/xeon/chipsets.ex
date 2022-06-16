defmodule PcZone.Chipsets do
  import PcZone.Helpers
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  import PcZone.Helpers
  alias PcZone.{Repo, Chipset}

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(Chipset, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Chipset
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(entities, opts \\ []) do
    entities =
      Enum.map(entities, fn entity ->
        entity
        |> ensure_slug
        |> PcZone.Chipset.new_changeset()
        |> PcZone.Helpers.get_changeset_changes()
      end)

    Repo.insert_all(
      Chipset,
      entities,
      Keyword.merge(opts, on_conflict: :replace_all, conflict_target: [:slug])
    )
  end

  def upsert_chipset_processors(entities, opts \\ []) do
    chipset_codes =
      Enum.map(entities, fn
        %{"code" => code} -> code
        %{code: code} -> code
        _ -> nil
      end)
      |> Enum.filter(&(&1 != nil))

    processor_codes =
      Enum.flat_map(entities, fn
        %{"processors" => processor_codes = [_ | _]} -> processor_codes
        %{processors: processor_codes = [_ | _]} -> processor_codes
        _ -> []
      end)
      |> Enum.filter(&(&1 != nil))

    chipsets_map = get_map_by_code(chipset_codes)
    processors_map = PcZone.Processors.get_map_by_code(processor_codes)

    entities =
      Enum.flat_map(entities, fn
        %{code: code, processors: processors = [_ | _]} ->
          Enum.map(
            processors,
            &%{
              chipset_id: chipsets_map[code],
              processor_id: processors_map[&1]
            }
          )

        %{"code" => code, "processors" => processors = [_ | _]} ->
          Enum.map(
            processors,
            &%{
              chipset_id: chipsets_map[code],
              processor_id: processors_map[&1]
            }
          )

        _ ->
          []
      end)
      |> Enum.filter(&(&1.chipset_id != nil && &1.processor_id != nil))

    Repo.insert_all(PcZone.ChipsetProcessor, entities, opts)
  end

  def import_chipsets() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/pczone")

    cursor =
      Mongo.find(conn, "IntelChipset", %{
        "attributes.0" => %{"$exists" => true},
        "processors.0" => %{"$exists" => true}
      })

    entities = Enum.map(cursor, &parse/1)
    Repo.insert_all(Chipset, entities, on_conflict: :replace_all, conflict_target: [:code])
  end

  def get_map_by_code() do
    Repo.all(from(c in Chipset, select: {c.code, c.id})) |> Enum.into(%{})
  end

  def get_map_by_code(codes) when is_list(codes) do
    Repo.all(from(c in Chipset, where: c.code in ^codes, select: {c.code, c.id}))
    |> Enum.into(%{})
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
      code: parse_code(name),
      attributes: parse_attributes(attributes)
    })
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :code -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  defp parse_code(name) do
    name
    |> String.replace("Intel® Communications", "")
    |> String.replace("Intel® ", "")
    |> String.replace(" Chipset", "")
  end
end
