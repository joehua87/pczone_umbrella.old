defmodule PczoneWeb.FileController do
  use PczoneWeb, :controller

  def report_file(conn, %{"path" => path}) do
    file = Path.join([Pczone.Reports.get_report_dir()] ++ path)
    mime = MIME.from_path(file)

    conn
    |> put_resp_header("content-type", mime)
    |> send_file(200, file)
  end

  def media_file(conn, %{"path" => path}) do
    file = Path.join([Application.get_env(:pczone, :media_dir), "default"] ++ path)
    mime = MIME.from_path(file)

    conn
    |> put_resp_header("content-type", mime)
    |> send_file(200, file)
  end

  def new_media(conn, %{"files" => files}) do
    with {:ok, result} <- Pczone.Media.bulk_upload(files) do
      json(conn, result)
    end
  end
end
