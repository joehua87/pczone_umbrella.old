defmodule PcZone.Fixtures do
  import Ecto.Query, only: [from: 2]

  def get_fixtures_dir() do
    __ENV__.file |> Path.dirname() |> Path.join("data")
  end

  def read_fixture(name, _opts \\ []) when is_bitstring(name) do
    path = Path.join([get_fixtures_dir(), name])
    ext = Path.extname(path)

    case ext do
      ".json" -> path |> File.read!() |> Jason.decode!()
      ".yml" -> path |> YamlElixir.read_from_file!()
      _ -> {:error, "File not found"}
    end
  end

  def simple_builts_fixture() do
    list = PcZone.Fixtures.read_fixture("simple_builts.yml")
    codes = Enum.map(list, & &1["code"])
    {:ok, _} = PcZone.SimpleBuilts.upsert(list)

    PcZone.Repo.all(
      from b in PcZone.SimpleBuilt,
        where: b.code in ^codes,
        preload: [
          :barebone,
          :barebone_product,
          {:processors, [:processor_product, :gpu_product]},
          {:memories, :memory_product},
          {:hard_drives, :hard_drive_product}
        ],
        limit: 1
    )
  end
end
