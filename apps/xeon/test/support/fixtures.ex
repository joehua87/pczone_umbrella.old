defmodule Xeon.Fixtures do
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
end
