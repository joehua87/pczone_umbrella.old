defmodule Pczone.Reports do
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  alias Pczone.Repo

  def get(attrs = %{}) when is_map(attrs), do: get(struct(Dew.Filter, attrs))

  def get(id) do
    Repo.get(Pczone.Report, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Report
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, ["name", "inserted_at"])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        :type -> parse_string_filter(acc, field, value)
        :category -> parse_string_filter(acc, field, value)
        :inserted_at -> parse_datetime_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  def get_report_absolute_path(%Pczone.Report{path: path}) do
    Path.join(get_report_dir(), path)
  end

  def get_report_dir() do
    Application.get_env(:pczone, :report_dir)
  end
end
