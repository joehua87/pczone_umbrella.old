defmodule PcZoneWeb.PageController do
  use PcZoneWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
