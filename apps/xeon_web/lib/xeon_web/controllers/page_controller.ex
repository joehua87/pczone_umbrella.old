defmodule XeonWeb.PageController do
  use XeonWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
