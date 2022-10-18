defmodule Pczone.Chipsets do
  import Pczone.Helpers
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  import Pczone.Helpers
  alias Pczone.{Repo, Chipset}

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
    with list when is_list(list) <-
           Pczone.Helpers.get_list_changset_changes(
             entities,
             fn entity ->
               entity
               |> ensure_slug()
               |> Pczone.Chipset.new_changeset()
               |> Pczone.Helpers.get_changeset_changes()
             end
           ) do
      Repo.insert_all_2(
        Chipset,
        list,
        [
          on_conflict:
            {:replace,
             [
               :code,
               :code_name,
               :name,
               :launch_date,
               :collection_name,
               :vertical_segment,
               :status
             ]},
          conflict_target: [:slug]
        ] ++ opts
      )
    end
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
    processors_map = Pczone.Processors.get_map_by_code(processor_codes)

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

    Repo.insert_all_2(Pczone.ChipsetProcessor, entities, [on_conflict: :nothing] ++ opts)
  end

  def import_chipsets() do
    cursor =
      Mongo.find(:mongo, "IntelChipset", %{
        "attributes.0" => %{"$exists" => true},
        "processors.0" => %{"$exists" => true}
      })

    entities = Enum.map(cursor, &parse/1)
    Repo.insert_all_2(Chipset, entities, on_conflict: :replace_all, conflict_target: [:code])
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
