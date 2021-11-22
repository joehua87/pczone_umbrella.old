defmodule Xeon.Helpers.GoogleSheets do
  import GoogleApi.Sheets.V4.Api.Spreadsheets

  def read_doc(conn, range) when is_bitstring(range) do
    sheet_id = sheet_id()
    {:ok, %{values: values}} = sheets_spreadsheets_values_get(conn, sheet_id, range)
    rows_to_items(values)
  end

  defp rows_to_items([headers | rows]) when is_list(headers) and is_list(rows) do
    headers = Enum.map(headers, &normalize_cell/1)

    rows
    |> Enum.filter(&(Enum.at(&1, 0) != nil))
    |> Enum.map(fn row ->
      headers
      |> Enum.with_index()
      |> Enum.map(fn {header, index} ->
        {header, normalize_cell(Enum.at(row, index))}
      end)
      |> Enum.into(%{})
    end)
  end

  def get_connection do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    GoogleApi.Sheets.V4.Connection.new(token.token)
  end

  defp sheet_id() do
    Application.get_env(:xeon, :sheet_id)
  end

  defp normalize_cell(nil), do: nil

  defp normalize_cell(value) do
    case String.trim(value) do
      "" ->
        nil

      v ->
        v
        |> String.replace("\b", "")
        |> String.replace("\r", "")
        |> String.replace(<<29>>, "")
        |> to_string()
    end
  end
end
