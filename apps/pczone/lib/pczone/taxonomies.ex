defmodule Pczone.Taxonomies do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.Repo

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(Pczone.Taxonomy, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    make_query(filter)
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def make_query(filter) do
    Pczone.Taxonomy
    |> where(^parse_filter(filter))
  end

  @doc """
  Upsert a list of taxonomies
  """
  def upsert(list, opts \\ []) do
    list =
      list
      |> Enum.map(fn %{"code" => code} = item ->
        name =
          case Map.get(item, "name") do
            nil -> Recase.to_title(code)
            "" -> Recase.to_title(code)
            name -> name
          end

        %{code: code, name: name}
      end)

    Repo.insert_all_2(
      Pczone.Taxonomy,
      list,
      [on_conflict: {:replace, [:name, :description]}, conflict_target: [:code]] ++ opts
    )
  end

  @doc """
  Upsert taxonomies with taxonomy items from xlsx file
  """
  def upsert_from_xlsx(path) do
    taxonomies = Pczone.Xlsx.read_spreadsheet(path, 1)
    taxons = Pczone.Xlsx.read_spreadsheet(path, 2)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:taxonomies, fn _, _ ->
      upsert(taxonomies, returning: true)
    end)
    |> Ecto.Multi.run(:taxons, fn _, %{taxonomies: {_, taxonomies}} ->
      taxonomies_map =
        taxonomies |> Enum.map(fn %{code: code} = item -> {code, item} end) |> Enum.into(%{})

      Pczone.Taxons.upsert(taxons, taxonomies_map)
    end)
    |> Repo.transaction()
  end

  def get_map_by_code() do
    Repo.all(from a in Pczone.Taxonomy, select: {a.code, a})
    |> Enum.into(%{})
  end

  def get_map_by_code(codes) do
    Repo.all(from a in Pczone.Taxonomy, select: {a.code, a}, where: a.code in ^codes)
    |> Enum.into(%{})
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :code -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
