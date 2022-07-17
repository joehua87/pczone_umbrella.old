defmodule PczoneWeb.UpsertController do
  use PczoneWeb, :controller

  def products(conn, %{"file" => %Plug.Upload{path: path}}) do
    path
    |> Pczone.Xlsx.read_spreadsheet()
    |> Pczone.Products.upsert()

    json(conn, %{})
  end
end
