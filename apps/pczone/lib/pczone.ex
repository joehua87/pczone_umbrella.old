defmodule Pczone do
  @moduledoc """
  Pczone keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_upsert_files_from_google_drive(folder_id \\ nil) do
    folder_id = folder_id || "1-wKKakuaLX34unJm5WTOwj3wL7mHEeF9"
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/drive")
    conn = GoogleApi.Drive.V3.Connection.new(token.token)

    {:ok, %GoogleApi.Drive.V3.Model.FileList{files: files}} =
      GoogleApi.Drive.V3.Api.Files.drive_files_list(conn, q: "'#{folder_id}' in parents")

    {:ok, dir} = Temp.mkdir("pczone-data")

    files
    |> Enum.map(fn
      %{id: _id} = file -> file
      %{"id" => id, "name" => name} -> %{id: id, name: name}
    end)
    |> Task.async_stream(
      fn %{id: id, name: name} ->
        path = Path.join(dir, name)

        with {:ok, %{body: body}} <-
               GoogleApi.Drive.V3.Api.Files.drive_files_get(conn, id, alt: "media") do
          File.write!(path, body)
          path
        end
      end,
      max_concurrency: 4,
      timeout: 30_000
    )
    |> Enum.map(fn {:ok, path} -> path end)
  end

  def initial_data(dir) when is_bitstring(dir) do
    dir
    |> Path.join("*")
    |> Path.wildcard()
    |> initial_data()
  end

  def initial_data(files) when is_list(files) do
    platforms = read_from_files!(files, ~r/^platforms.*?\.(ya?ml|xlsx)/)
    barebones = read_from_files!(files, ~r/^barebones.*?\.(ya?ml|xlsx)/)
    brands = read_from_files!(files, ~r/^brands.*?\.(ya?ml|xlsx)/)
    chassises = read_from_files!(files, ~r/^chassises.*?\.(ya?ml|xlsx)/)
    chipsets = read_from_files!(files, ~r/^chipsets.*?\.(ya?ml|xlsx)/)
    gpus = read_from_files!(files, ~r/^gpus.*?\.(ya?ml|xlsx)/)
    hard_drives = read_from_files!(files, ~r/^hard_drives.*?\.(ya?ml|xlsx)/)
    memories = read_from_files!(files, ~r/^memories.*?\.(ya?ml|xlsx)/)
    motherboards = read_from_files!(files, ~r/^motherboards.*?\.(ya?ml|xlsx)/)
    processors = read_from_files!(files, ~r/^processors.*?\.(ya?ml|xlsx)/)
    psus = read_from_files!(files, ~r/^psus.*?\.(ya?ml|xlsx)/)
    heatsinks = read_from_files!(files, ~r/^heatsinks.*?\.(ya?ml|xlsx)/)
    products = read_from_files!(files, ~r/^products.*?\.(ya?ml|xlsx)/)

    with {:ok, _} <- Pczone.Platforms.upsert(platforms),
         {:ok, _} <- Pczone.Brands.upsert(brands),
         {:ok, _} <- Pczone.Chipsets.upsert(chipsets),
         {:ok, _} <- Pczone.Motherboards.upsert(motherboards),
         {:ok, _} <- Pczone.Processors.upsert(processors),
         {:ok, _} <- Pczone.Memories.upsert(memories),
         {:ok, _} <- Pczone.HardDrives.upsert(hard_drives),
         {:ok, _} <- Pczone.Gpus.upsert(gpus),
         {:ok, _} <- Pczone.Chassises.upsert(chassises),
         {:ok, _} <- Pczone.Psus.upsert(psus),
         {:ok, _} <- Pczone.Heatsinks.upsert(heatsinks),
         {:ok, _} <- Pczone.Barebones.upsert(barebones),
         {:ok, _} <- Pczone.Chipsets.upsert_chipset_processors(chipsets),
         {:ok, _} <- Pczone.Motherboards.upsert_motherboard_processors(motherboards),
         {:ok, _} <- Pczone.Products.upsert(products) do
      true
    end
  end

  def read_from_files!(files, name_pattern) do
    files
    |> Enum.filter(&(&1 |> Path.basename() |> String.match?(name_pattern)))
    |> Enum.map(fn file ->
      cond do
        String.match?(file, ~r/\.ya?ml/) ->
          YamlElixir.read_all_from_file!(file)

        String.match?(file, ~r/\.xlsx/) ->
          Pczone.Xlsx.read_spreadsheet(file)

        true ->
          []
      end
    end)
    |> List.flatten()
  end
end
