defmodule PcZoneWeb.UpsertController do
  use PcZoneWeb, :controller

  def products(conn, %{"file" => %Plug.Upload{path: path}}) do
    path
    |> PcZone.Products.read_xlsx()
    |> PcZone.Products.upsert()
    |> IO.inspect()

    json(conn, %{})
  end
end
