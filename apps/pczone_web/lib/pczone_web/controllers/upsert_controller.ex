defmodule PczoneWeb.UpsertController do
  use PczoneWeb, :controller

  def products(conn, %{"file" => %Plug.Upload{path: path}}) do
    path
    |> Pczone.Xlsx.read_spreadsheet()
    |> Pczone.Products.upsert()

    json(conn, %{})
  end

  def simple_built_platforms(conn, %{
        "platform_id" => platform_id,
        "file" => %Plug.Upload{path: path}
      }) do
    Pczone.Platforms.upsert_simple_built_platforms(platform_id, path)

    json(conn, %{})
  end

  def simple_built_variant_platforms(conn, %{
        "platform_id" => platform_id,
        "file" => %Plug.Upload{path: path}
      }) do
    Pczone.Platforms.upsert_simple_built_variant_platforms(platform_id, path)
    json(conn, %{})
  end
end
