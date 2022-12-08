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
    {:ok, store} =
      Pczone.Stores.create(%{
        code: "76922911",
        name: "xeonstorevn",
        platform: "shopee",
        rate: 1.05
      })

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

  def tax_info_fixture() do
    %{
      name: "CÔNG TY CP KẾT NỐI PHONG CÁCH SỐNG",
      tax_id: "0313496812",
      address:
        "Tầng 1, số 4, Nguyễn Thị Minh Khai, Phường Đa Kao, Quận 1, Thành phố Hồ Chí Minh, Việt Nam"
    }
  end
end
