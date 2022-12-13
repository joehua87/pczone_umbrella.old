defmodule Pczone.Regions do
  use GenServer
  @impl true
  def init(_opts) do
    {:ok, get()}
  end

  def get_provinces() do
    GenServer.call(__MODULE__, :get_provinces)
  end

  def get_districts(province_id) do
    GenServer.call(__MODULE__, {:get_districts, province_id})
  end

  def get_wards(district_id) do
    GenServer.call(__MODULE__, {:get_wards, district_id})
  end

  def get_ward(ward_id) do
    GenServer.call(__MODULE__, {:get_ward, ward_id})
  end

  @impl true
  def handle_call(:get_provinces, _from, state = %{provinces: provinces}) do
    {:reply, provinces, state}
  end

  @impl true
  def handle_call({:get_districts, province_id}, _from, state = %{districts_map: districts_map}) do
    {:reply, districts_map[province_id], state}
  end

  @impl true
  def handle_call({:get_wards, district_id}, _from, state = %{wards_map: wards_map}) do
    {:reply, wards_map[district_id], state}
  end

  @impl true
  def handle_call({:get_ward, ward_id}, _from, state = %{ward_map: ward_map}) do
    {:reply, ward_map[ward_id], state}
  end

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get() do
    items =
      :code.priv_dir(:pczone)
      |> Path.join("regions.json")
      |> File.read!()
      |> Jason.decode!()

    provinces =
      items
      |> Enum.uniq_by(& &1["province_id"])
      |> Enum.map(fn %{"province_id" => id, "province_name" => name} ->
        %{"id" => id, "name" => name}
      end)

    districts_map =
      items
      |> Enum.group_by(& &1["province_id"])
      |> Enum.map(fn {province_id, list} ->
        {province_id,
         list
         |> Enum.uniq_by(& &1["district_id"])
         |> Enum.map(fn %{"district_id" => id, "district_name" => name} ->
           %{"id" => id, "name" => name}
         end)}
      end)
      |> Enum.into(%{})

    wards_map =
      items
      |> Enum.group_by(& &1["district_id"])
      |> Enum.map(fn {district_id, list} ->
        {district_id,
         list
         |> Enum.uniq_by(& &1["ward_id"])
         |> Enum.map(fn %{"ward_id" => id, "ward_name" => name} ->
           %{"id" => id, "name" => name}
         end)}
      end)
      |> Enum.into(%{})

    ward_map =
      items
      |> Enum.map(fn %{
                       "ward_id" => id,
                       "province_name" => province_name,
                       "district_name" => district_name,
                       "ward_name" => ward_name
                     } ->
        {id,
         %{
           id: id,
           name: Enum.join([ward_name, district_name, province_name], ", "),
           province_name: province_name,
           district_name: district_name,
           ward_name: ward_name
         }}
      end)
      |> Enum.into(%{})

    %{
      provinces: provinces,
      districts_map: districts_map,
      wards_map: wards_map,
      ward_map: ward_map
    }
  end
end
