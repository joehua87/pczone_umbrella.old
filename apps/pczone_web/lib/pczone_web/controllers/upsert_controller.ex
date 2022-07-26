defmodule PczoneWeb.UpsertController do
  use PczoneWeb, :controller
  import Plug.Conn
  import Phoenix.Controller

  def products(conn, %{"file" => %Plug.Upload{path: path}}) do
    path
    |> Pczone.Xlsx.read_spreadsheet()
    |> Pczone.Products.upsert()

    json(conn, %{})
  end

  def simple_builts(conn, %{"file" => %Plug.Upload{path: path}}) do
    with {:ok, data} <- YamlElixir.read_from_file(path),
         {:ok, _} <- Pczone.SimpleBuilts.upsert(data) do
      json(conn, %{})
    else
      _reason ->
        json(conn, %{}) |> put_status(400)
    end
  end

  def simple_built_platforms(conn, %{
        # "platform_id" => platform_id,
        "file" => %Plug.Upload{path: path}
      }) do
    # Assume we have only Shopee
    platform_id = 1

    Pczone.Platforms.upsert_simple_built_platforms(platform_id, path)
    |> IO.inspect(label: "XXXXXX")

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
