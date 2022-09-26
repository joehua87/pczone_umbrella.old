defmodule Pczone.Fixtures do
  import Ecto.Query, only: [from: 2]

  def get_fixtures_dir() do
    __ENV__.file |> Path.dirname() |> Path.join("data")
  end

  def get_fixture_path(name) do
    Path.join([__ENV__.file |> Path.dirname(), "data", name])
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

  def built_templates_fixture() do
    list = Pczone.Fixtures.read_fixture("built_templates.yml")
    codes = Enum.map(list, & &1["code"])
    {:ok, _} = Pczone.BuiltTemplates.upsert(list)

    Pczone.Repo.all(
      from b in Pczone.BuiltTemplate,
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

  def address_fixture() do
    %{
      first_name: "Dew",
      last_name: "John",
      full_name: "Dew John",
      address1: "123 Some Street",
      zipcode: "111111",
      ward: "ward_code",
      district: "district_code",
      province: "province_code",
      region_code: "province_code:district_code:ward_code",
      region: "Pretty region name",
      email: "valid_email@company.com",
      phone: "123123123"
    }
  end
end
