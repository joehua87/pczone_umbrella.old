defmodule Pczone.Media do
  import Ecto.Query, only: [from: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, Medium}

  def list(params \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        order_by: order_by
      }) do
    from(i in Medium, where: ^parse_filter(filter))
    |> sort_by(order_by, ["updated_at", "inserted_at"])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create(params) do
    params
    |> Medium.new()
    |> Repo.insert()
  end

  def upload(%{path: uploaded_path, filename: filename} = upload) do
    path = get_image_path(filename)

    with %{} = params <- make_image_params(upload),
         %Ecto.Changeset{valid?: true} = changeset <- Medium.new(params),
         {:ok, %Medium{id: id, ext: ext}} = result <- Repo.insert(changeset),
         :ok <- File.mkdir_p(Path.dirname(path)),
         {:ok, _} <- File.copy(uploaded_path, path) do
      if String.downcase(ext) in [".jpg", ".jpeg", ".png"] do
        transform(id)
      end

      result
    else
      %Ecto.Changeset{} = changeset -> {:error, changeset}
      error -> error
    end
  end

  def transform_all() do
    media = Repo.all(Medium)

    Task.async_stream(
      media,
      fn %{id: id} ->
        path = Enum.join([media_dir(), "derived/p_l", id], "/")

        if !File.exists?(path) do
          transform(id)
        else
          IO.puts("#{id} exists")
        end
      end,
      max_concurrency: 8,
      timeout: 30_000
    )
    |> Enum.into([])
  end

  def transform(id) do
    presets = [
      %{
        code: "xs",
        operations: [%{action: "resize", params: %{width: 100}}]
      },
      %{
        code: "s",
        operations: [%{action: "resize", params: %{width: 200}}]
      },
      %{
        code: "m",
        operations: [%{action: "resize", params: %{width: 400}}]
      },
      %{
        code: "l",
        operations: [%{action: "resize", params: %{width: 800}}]
      },
      %{
        code: "xl",
        operations: [%{action: "resize", params: %{width: 1200}}]
      }
    ]

    args = ["default", id, "-p", Jason.encode!(presets)]

    case System.cmd(
           "dew-media",
           args,
           env: [{"DEWCMS_ASSETS_DIR", media_dir()}]
         ) do
      {_, 0} ->
        Repo.get(Medium, id) |> Ecto.Changeset.change(%{status: :uploaded}) |> Repo.update()

      _ ->
        {:error, "Cannot transform"}
    end
  end

  def bulk_upload(plug_uploads) do
    images =
      Task.async_stream(
        plug_uploads,
        fn item ->
          with {:ok, image} <- upload(item) do
            image
          end
        end,
        max_concurrency: 8,
        timeout: 30_000
      )
      |> Enum.filter(&(elem(&1, 0) == :ok))
      |> Enum.map(&elem(&1, 1))
      |> Enum.to_list()

    {:ok, images}
  end

  @doc """
  Ensure all media files is uploaded to database
  """
  def sync_media(uploads) do
    entities = Enum.map(uploads, &make_image_params/1)
    ids = Enum.map(entities, & &1.id)

    exists_media_map =
      Repo.all(from m in Medium, where: m.id in ^ids, select: {m.id, m.size})
      |> Enum.into(%{})

    entities_to_upload =
      Enum.filter(entities, fn %{id: id, size: size} ->
        !Decimal.eq?(Map.get(exists_media_map, id, 0), size)
      end)

    map = Enum.map(uploads, &{&1.filename, &1.path}) |> Enum.into(%{})
    ensure_image_path!()

    with {:ok, {_, media}} <-
           Repo.insert_all_2(Medium, entities_to_upload,
             on_conflict: {:replace, [:size]},
             conflict_target: [:id],
             returning: true
           ) do
      Task.async_stream(
        media,
        fn %{id: id} ->
          source = map[id]
          dest = get_image_path(id)
          File.copy!(source, dest)
          transform(id)
        end,
        max_concurrency: 8,
        timeout: 30_000
      )
      |> Enum.into([])

      {:ok, media}
    end
  end

  def check_image(%{id: id, size: size}) do
    case File.stat(get_image_path(id)) do
      {:ok, %{size: ^size}} -> true
      _ -> false
    end
  end

  def upload_dir(dir) do
    params =
      File.ls!(dir)
      |> Enum.reduce([], fn filename, acc ->
        ext = Path.extname(filename) |> String.downcase()

        case Enum.member?(~w(.jpg .jpeg .gif .png .webp), ext) do
          true -> acc ++ [%{filename: filename, path: Path.absname(filename, dir)}]
          _ -> acc
        end
      end)

    bulk_upload(params)
  end

  def delete(id) when is_bitstring(id) do
    case Repo.one(from Medium, where: [id: ^id]) do
      nil ->
        {:error, :not_found}

      image ->
        with {:ok, image} <- Repo.delete(image) do
          delete_image_files(id)
          {:ok, image}
        end
    end
  end

  def delete_image_files(id) do
    path = get_image_path(id)
    transform_paths = get_transformed_images_path(id)
    paths = [path] ++ transform_paths

    Enum.each(paths, fn path ->
      File.rm(path)
    end)
  end

  defp make_image_params(%{filename: filename, path: path}) do
    now = DateTime.utc_now()

    with {:ok, size} <- get_size(path) do
      %{
        id: filename,
        name: filename,
        ext: Path.extname(filename),
        size: size,
        status: :in_process,
        inserted_at: now,
        updated_at: now
      }
    end
  end

  def get_image_path(id) do
    Path.join([media_dir(), "default/origin", id])
  end

  def ensure_image_path!() do
    Path.join([media_dir(), "default/origin"]) |> File.mkdir_p!()
  end

  def parse_filter(filter \\ %{}) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_string_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        :status -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  defp get_size(path) do
    case File.stat(path) do
      {:ok, %{size: size}} -> {:ok, size}
      err -> err
    end
  end

  defp media_dir(), do: Application.get_env(:pczone, :media_dir)

  defp get_transformed_images_path(id) do
    ext = Path.extname(id)
    webp_id = String.replace(id, ext, ".webp")
    prefix = Path.join([media_dir(), "derived/**"])
    files = Path.join([prefix, id]) |> Path.wildcard()
    webp_files = Path.join([prefix, webp_id]) |> Path.wildcard()
    Enum.uniq(files ++ webp_files)
  end
end
