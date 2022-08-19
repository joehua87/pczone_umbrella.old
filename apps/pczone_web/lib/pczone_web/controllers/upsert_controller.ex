defmodule PczoneWeb.UpsertController do
  use PczoneWeb, :controller
  import Plug.Conn
  import Phoenix.Controller

  def barebones(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Barebones.upsert/1)
  end

  def brands(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Brands.upsert/1)
  end

  def chassises(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Chassises.upsert/1)
  end

  def chipsets(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Chipsets.upsert/1)
  end

  def extension_devices(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.ExtensionDevices.upsert/1)
  end

  def gpus(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Gpus.upsert/1)
  end

  def hard_drives(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.HardDrives.upsert/1)
  end

  def heatsinks(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Heatsinks.upsert/1)
  end

  def memories(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Memories.upsert/1)
  end

  def motherboards(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Motherboards.upsert/1)
  end

  def processors(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Processors.upsert/1)
  end

  def psus(conn, %{"file" => %Plug.Upload{} = file} = upload) do
    IO.inspect(upload)
    upsert(conn, file, &Pczone.Psus.upsert/1)
  end

  def products(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.Products.upsert/1)
  end

  def simple_builts(conn, %{"file" => %Plug.Upload{} = file}) do
    upsert(conn, file, &Pczone.SimpleBuilts.upsert/1)
  end

  def simple_built_stores(conn, %{
        # "store_id" => store_id,
        "file" => %Plug.Upload{path: path}
      }) do
    # Assume we have only Shopee
    store_id = 1
    Pczone.Stores.upsert_simple_built_stores(store_id, path)
    json(conn, %{})
  end

  def simple_built_variant_stores(conn, %{
        # "store_id" => store_id,
        "file" => %Plug.Upload{path: path}
      }) do
    # Assume we have only Shopee
    store_id = 1
    Pczone.Stores.upsert_simple_built_variant_stores(store_id, path)
    json(conn, %{})
  end

  defp upsert(conn, file, func) do
    file
    |> Pczone.Helpers.read_data()
    |> IO.inspect()
    |> func.()
    |> IO.inspect(label: "XXXXXXTTT")

    json(conn, %{})
  end
end
