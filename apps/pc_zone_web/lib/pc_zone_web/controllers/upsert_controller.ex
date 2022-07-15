defmodule PcZoneWeb.UpsertController do
  use PcZoneWeb, :controller

  def products(conn, %{"file" => %Plug.Upload{path: path}}) do
    path
    |> PcZone.Xlsx.read_spreadsheet()
    |> PcZone.Products.upsert()

    json(conn, %{})
  end
end
