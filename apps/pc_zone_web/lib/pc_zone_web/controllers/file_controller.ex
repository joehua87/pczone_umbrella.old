defmodule PcZoneWeb.FileController do
  use PcZoneWeb, :controller

  def report_file(conn, %{"path" => path}) do
    file = Path.join([PcZone.Reports.get_report_dir()] ++ path)
    mime = MIME.from_path(file)

    conn
    |> put_resp_header("content-type", mime)
    |> send_file(200, file)
  end

  def media_file(conn, %{"path" => path}) do
    file = Path.join([Application.get_env(:pc_zone, :media_dir), "default"] ++ path)
    mime = MIME.from_path(file)

    conn
    |> put_resp_header("content-type", mime)
    |> send_file(200, file)
  end

  def new_media(conn, %{"files" => files}) do
    with {:ok, result} <- PcZone.Media.bulk_upload(files) do
      json(conn, result)
    end
  end
end
