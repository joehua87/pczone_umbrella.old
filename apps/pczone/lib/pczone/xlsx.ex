defmodule Pczone.Xlsx do
  @doc """
  Read data of a from a xlsx file, sheet_index start with 1
  """
  def read_spreadsheet(path, sheet_index \\ 1) when is_bitstring(path) do
    with [{:ok, _} | _] = list <- Xlsxir.multi_extract(path),
         {:ok, sheet} <- Enum.at(list, sheet_index - 1) do
      sheet
      |> Xlsxir.get_list()
      |> spreadsheet_to_list()
    end
  end

  def spreadsheet_to_list([headers | rows]) when is_list(headers) and is_list(rows) do
    rows
    |> Enum.map(fn row ->
      row
      |> Enum.with_index(fn cell, index ->
        {Enum.at(headers, index), cell}
      end)
      |> Enum.filter(&(elem(&1, 0) != nil))
      |> Enum.into(%{})
    end)
  end
end
