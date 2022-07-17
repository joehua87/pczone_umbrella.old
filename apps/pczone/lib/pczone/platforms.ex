defmodule Pczone.Platforms do
  import Ecto.Query, only: [from: 2]
  alias Elixlsx.{Sheet, Workbook}
  alias Pczone.{Repo, Platform, SimpleBuiltVariant, SimpleBuiltVariantPlatform}

  def create(params) do
    params
    |> Pczone.Platform.new_changeset()
    |> Pczone.Repo.insert()
  end

  @doc """
  Upsert simple built variants for a specific platform
  """
  def upsert_simple_built_variants(platform_id, list) do
    list = list |> Enum.map(&parse_item(platform_id, &1))

    Repo.insert_all_2(SimpleBuiltVariantPlatform, list,
      conflict_target: [:platform_id, :simple_built_variant_id],
      on_conflict: {:replace, [:product_code, :variant_code]}
    )
  end

  def read_platform_simple_built_variants(path) do
    [{:ok, sheet_1} | _] = Xlsxir.multi_extract(path)
    [headers | rows] = Xlsxir.get_list(sheet_1)

    rows
    |> Enum.map(fn row ->
      row
      |> Enum.with_index(fn cell, index ->
        {Enum.at(headers, index), cell}
      end)
      |> Enum.filter(&(elem(&1, 0) != nil))
      |> Enum.into(%{})
    end)
  end

  def generate_platform_pricing_report(platform_id) do
    platform = Repo.get(Platform, platform_id)
    date = Date.utc_today() |> Calendar.strftime("%Y-%m")
    now = DateTime.utc_now() |> DateTime.to_unix()
    name = "#{platform.code}-product-pricing-#{now}"
    type = "xlsx"
    path = "#{date}/#{name}.#{type}"
    absolute_path = Path.join(Pczone.Reports.get_report_dir(), path)

    with {:ok, _} <- make_platform_pricing_workbook(platform) |> Elixlsx.write_to(absolute_path) do
      %{size: size} = File.stat!(absolute_path)

      %{
        name: name,
        type: type,
        category: "platform-product-pricing",
        path: path,
        size: size
      }
      |> Pczone.Report.new_changeset()
      |> Repo.insert()
    end
  end

  def make_platform_pricing_workbook(%Platform{rate: rate}) do
    rows =
      Repo.all(
        from vp in SimpleBuiltVariantPlatform,
          preload: [simple_built_variant: [:simple_built]],
          where: not is_nil(vp.variant_code)
      )
      |> Enum.map(fn %SimpleBuiltVariantPlatform{
                       product_code: product_code,
                       variant_code: variant_code,
                       simple_built_variant: %SimpleBuiltVariant{
                         simple_built: simple_built,
                         option_values: option_values,
                         total: total
                       }
                     } ->
        [
          # Mã Sản phẩm
          product_code,
          # Tên Sản phẩm
          simple_built.name,
          # Mã Phân loại
          variant_code,
          # Tên phân loại
          Enum.join(option_values, "; "),
          # SKU Sản phẩm
          "",
          # SKU
          "",
          # Giá
          Decimal.mult(total, rate) |> Decimal.to_integer(),
          # Số lượng
          999
        ]
      end)

    %Workbook{
      sheets: [
        %Sheet{
          name: "Sheet1",
          rows:
            [
              [
                "Mã Sản phẩm",
                "Tên Sản phẩm",
                "Mã Phân loại",
                "Tên phân loại",
                "SKU Sản phẩm",
                "SKU",
                "Giá",
                "Số lượng"
              ]
            ] ++ rows
        }
      ]
    }
  end

  def make_platform_pricing_workbook(platform_id) do
    Repo.get(Platform, platform_id) |> make_platform_pricing_workbook
  end

  defp parse_item(platform_id, %{
         "id" => simple_built_variant_id,
         "product_code" => product_code,
         "variant_code" => variant_code
       }) do
    %{
      platform_id: platform_id,
      simple_built_variant_id: simple_built_variant_id,
      product_code: product_code,
      variant_code: variant_code
    }
  end
end
