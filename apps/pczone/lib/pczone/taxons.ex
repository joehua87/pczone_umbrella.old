defmodule Pczone.Taxons do
  import Ecto.Query, only: [where: 2, from: 2]
  alias Pczone.Repo
  import Dew.FilterParser

  def get(id) do
    Repo.get(Pczone.Taxon, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Taxon
    |> where(^parse_filter(filter))
    |> parse_taxonomy_filter(filter)
    |> parse_products_filter(filter)
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

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

  def parse_filter(filter \\ %{}) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :path -> parse_ltree_filter(acc, field, value)
        :taxonomy_id -> parse_id_filter(acc, field, value)
        :featured -> parse_boolean_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  def parse_taxonomy_filter(acc, %{taxonomy: taxonomy_filter_input}) do
    taxonomy_ids_filter =
      from t in Pczone.Taxonomies.make_query(taxonomy_filter_input), select: t.id

    from t in acc, where: t.taxonomy_id in subquery(taxonomy_ids_filter)
  end

  def parse_taxonomy_filter(acc, _), do: acc

  def parse_products_filter(acc, %{products: product_filter_input}) do
    product_ids_query = from p in Pczone.Products.make_query(product_filter_input), select: p.id

    taxon_ids_query =
      from pt in Pczone.ProductTaxon,
        where: pt.product_id in ^product_ids_query,
        select: pt.taxon_id

    from t in acc, where: t.id in ^taxon_ids_query
  end

  def parse_products_filter(acc, _filter) do
    acc
  end

  def parse_built_templates_filter(acc, %{built_templates: built_template_filter_input}) do
    built_template_ids_query =
      from p in Pczone.BuiltTemplates.make_query(built_template_filter_input), select: p.id

    taxon_ids_query =
      from pt in Pczone.BuiltTemplateTaxon,
        where: pt.built_template_id in ^built_template_ids_query,
        select: pt.taxon_id

    from t in acc, where: t.id in ^taxon_ids_query
  end

  def parse_built_templates_filter(acc, _filter) do
    acc
  end
end
