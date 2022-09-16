defmodule Dew.FilterParser do
  import Ecto.Query, only: [dynamic: 1, dynamic: 2, order_by: 2, select: 2]

  def parse_string_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
        :neq -> join_exp(acc, dynamic([p], field(p, ^field_name) != ^value))
        :ilike -> join_exp(acc, dynamic([p], ilike(field(p, ^field_name), ^value)))
        :like -> join_exp(acc, dynamic([p], like(field(p, ^field_name), ^value)))
        :in -> join_exp(acc, dynamic([p], field(p, ^field_name) in ^value))
      end
    end)
  end

  def parse_path_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq ->
          join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))

        :in ->
          join_exp(
            acc,
            dynamic([p], fragment("? && ?", field(p, ^field_name), ^value))
          )

        :match ->
          join_exp(acc, dynamic([p], ^value in field(p, ^field_name)))
      end
    end)
  end

  def parse_atom_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      value = to_string(value)

      case compare_type do
        :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
        :neq -> join_exp(acc, dynamic([p], field(p, ^field_name) != ^value))
        :ilike -> join_exp(acc, dynamic([p], ilike(field(p, ^field_name), ^value)))
        :like -> join_exp(acc, dynamic([p], like(field(p, ^field_name), ^value)))
        :in -> join_exp(acc, dynamic([p], field(p, ^field_name) in ^value))
      end
    end)
  end

  def parse_string_filter_equal(queryable, field_name, value) do
    join_exp(queryable, dynamic([p], field(p, ^field_name) == ^value))
  end

  def parse_id_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
        :in -> join_exp(acc, dynamic([p], field(p, ^field_name) in ^value))
        :nin -> join_exp(acc, dynamic([p], field(p, ^field_name) not in ^value))
      end
    end)
  end

  def parse_boolean_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
        :neq -> join_exp(acc, dynamic([p], field(p, ^field_name) != ^value))
      end
    end)
  end

  def parse_array_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :all -> join_exp(acc, dynamic([p], fragment("? @> ?", field(p, ^field_name), ^value)))
        :any -> join_exp(acc, dynamic([p], fragment("? && ?", field(p, ^field_name), ^value)))
      end
    end)
  end

  def parse_integer_filter(queryable, field_name, filter_item),
    do: parse_comparable_filter(queryable, field_name, filter_item)

  def parse_decimal_filter(queryable, field_name, filter_item),
    do: parse_comparable_filter(queryable, field_name, filter_item)

  def parse_date_filter(queryable, field_name, filter_item),
    do: parse_comparable_filter(queryable, field_name, filter_item)

  def parse_time_filter(queryable, field_name, filter_item),
    do: parse_comparable_filter(queryable, field_name, filter_item)

  def parse_datetime_filter(queryable, field_name, filter_item),
    do: parse_comparable_filter(queryable, field_name, filter_item)

  def parse_ltree_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq ->
          join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))

        :match ->
          join_exp(acc, dynamic([p], fragment("? ~ ?", field(p, ^field_name), ^value)))
      end
    end)
  end

  def parse_fulltext_filter(queryable, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn
      {_compare_type, nil}, acc ->
        acc

      {_compare_type, ""}, acc ->
        acc

      {compare_type, value}, acc ->
        case compare_type do
          :websearch ->
            join_exp(
              acc,
              dynamic([p], fragment("websearch_to_tsquery('simple', ?) @@ ?", ^value, p.docs))
            )

          :phrase ->
            join_exp(
              acc,
              dynamic([p], fragment("phraseto_tsquery('simple', ?) @@ ?", ^value, p.docs))
            )

          :plain ->
            join_exp(
              acc,
              dynamic([p], fragment("plainto_tsquery('simple', ?) @@ ?", ^value, p.docs))
            )

          _ ->
            acc
        end
    end)
  end

  defp parse_comparable_filter(queryable, field_name, filter_item) do
    filter_item
    |> Enum.reduce(queryable, fn {compare_type, value}, acc ->
      case compare_type do
        :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
        :neq -> join_exp(acc, dynamic([p], field(p, ^field_name) != ^value))
        :gt -> join_exp(acc, dynamic([p], field(p, ^field_name) > ^value))
        :lt -> join_exp(acc, dynamic([p], field(p, ^field_name) < ^value))
        :gte -> join_exp(acc, dynamic([p], field(p, ^field_name) >= ^value))
        :lte -> join_exp(acc, dynamic([p], field(p, ^field_name) <= ^value))
      end
    end)
  end

  def join_exp(acc, exp) do
    case acc do
      nil -> exp
      _ -> dynamic(^acc and ^exp)
    end
  end

  def sort_by(queryable, order, white_list) when is_list(order) do
    order
    |> Enum.filter(fn %{field: field} ->
      Enum.member?(
        white_list,
        field
      )
    end)
    |> Enum.reduce(queryable, fn %{field: field_name, direction: order_direction}, acc_schema ->
      opts = [{order_direction, ensure_atom(field_name)}]

      acc_schema
      |> order_by(^opts)
    end)
  end

  def sort_by(acc, _), do: acc

  def select_fields(queryable, selection, map_fields \\ [])

  def select_fields(queryable, nil, _), do: queryable

  def select_fields(queryable, [], _), do: queryable

  def select_fields(queryable, selection, map_fields)
      when is_list(selection) and is_list(map_fields) do
    simple_select_fields =
      selection
      |> Enum.filter(&(elem(&1, 1) == [] || elem(&1, 0) in map_fields))
      |> Enum.map(&elem(&1, 0))

    case simple_select_fields do
      [] -> queryable
      _ -> select(queryable, ^simple_select_fields)
    end
  end

  defp ensure_atom(value) when is_bitstring(value), do: String.to_atom(value)
  defp ensure_atom(value) when is_atom(value), do: value
end
