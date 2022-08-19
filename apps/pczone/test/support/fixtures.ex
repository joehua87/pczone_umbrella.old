defmodule Pczone.Fixtures do
  import Ecto.Query, only: [from: 2]

  def get_fixtures_dir() do
    __ENV__.file |> Path.dirname() |> Path.join("data")
  end

  def read_fixture(name, _opts \\ []) when is_bitstring(name) do
    [get_fixtures_dir(), name]
    |> Path.join()
    |> Pczone.Helpers.read_data()
  end

  def store_fixture() do
    {:ok, store} = Pczone.Stores.create(%{code: "shopee", name: "Shopee", rate: 1.05})
    store
  end

  def simple_builts_fixture() do
    list = Pczone.Fixtures.read_fixture("simple_builts.yml")
    codes = Enum.map(list, & &1["code"])
    {:ok, _} = Pczone.SimpleBuilts.upsert(list)

    Pczone.Repo.all(
      from b in Pczone.SimpleBuilt,
        where: b.code in ^codes,
        preload: [
          :barebone,
          :barebone_product,
          {:processors, [:processor_product, :gpu_product]},
          {:memories, :memory_product},
          {:hard_drives, :hard_drive_product}
        ]
    )
  end
end
