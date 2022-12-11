defmodule PczoneWeb.RegionsController do
  use PczoneWeb, :controller

  import Phoenix.Controller

  def index(conn, params) do
    json(conn, get_data(params))
  end

  defp get_data(%{"ward_id" => ward_id}) do
    Pczone.Regions.get_ward(ward_id)
  end

  defp get_data(%{"district_id" => district_id}) do
    Pczone.Regions.get_wards(district_id)
  end

  defp get_data(%{"province_id" => province_id}) do
    Pczone.Regions.get_districts(province_id)
  end

  defp get_data(_) do
    Pczone.Regions.get_provinces()
  end
end
