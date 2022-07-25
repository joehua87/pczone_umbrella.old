defmodule Pczone.Platforms do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Elixlsx.{Sheet, Workbook}

  alias Pczone.{
    Repo,
    Platform,
    SimpleBuilt,
    SimpleBuiltPlatform,
    SimpleBuiltVariant,
    SimpleBuiltVariantPlatform,
    Xlsx
  }

  def get_by_code(code) do
    Repo.one(from(Platform, where: [code: ^code], limit: 1))
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Platform
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create(params) do
    params
    |> Pczone.Platform.new_changeset()
    |> Pczone.Repo.insert()
  end

  @doc """
  Use full to get product code, variant code
  """
  def read_product_variants("shopee", path) do
    with [{:ok, sheet} | _] <- Xlsxir.multi_extract(path),
         list <-
           Xlsxir.get_list(sheet)
           |> Enum.slice(3..-1)
           |> Xlsx.spreadsheet_to_list() do
      Enum.map(list, fn %{
                          "Giá" => _,
                          "Mã Phân loại" => variant_code,
                          "Mã Sản phẩm" => product_code,
                          "SKU" => _,
                          "SKU Sản phẩm" => _,
                          "Số lượng" => _,
                          "Tên Sản phẩm" => _,
                          "Tên phân loại" => variant_name
                        } ->
        %{
          product_code: product_code,
          variant_code: variant_code,
          variant_name: variant_name
        }
      end)
      |> Enum.filter(&(&1.product_code != nil))
    end
  end

  @doc """
  Read an xlsx file exported from platform.
  Extract variant_code by product_code & variant_name.
  Then upsert all to simple_built_variant_platform.
  """
  def upsert_simple_built_variant_platforms(
        %Platform{id: platform_id, code: platform_code},
        path,
        opts \\ []
      ) do
    list = read_product_variants(platform_code, path)
    product_codes = list |> Enum.map(& &1.product_code) |> Enum.uniq()

    product_codes_map_by_simple_built_id =
      Repo.all(
        from p in SimpleBuiltPlatform,
          where: p.product_code in ^product_codes,
          select: {p.simple_built_id, p.product_code}
      )
      |> Enum.into(%{})

    simple_built_ids = Map.keys(product_codes_map_by_simple_built_id)

    variants =
      Repo.all(from v in SimpleBuiltVariant, where: v.simple_built_id in ^simple_built_ids)

    variant_platforms =
      variants
      |> Enum.map(fn %SimpleBuiltVariant{
                       id: simple_built_variant_id,
                       name: name,
                       simple_built_id: simple_built_id
                     } ->
        product_code = product_codes_map_by_simple_built_id[simple_built_id]

        variant_code =
          case Enum.find(list, &(&1.product_code == product_code && &1.variant_name == name)) do
            %{variant_code: variant_code} -> variant_code
            _ -> nil
          end

        %{
          platform_id: platform_id,
          simple_built_variant_id: simple_built_variant_id,
          product_code: product_code,
          variant_code: variant_code
        }
      end)
      |> Enum.filter(&(&1.variant_code != nil))

    Repo.insert_all_2(
      Pczone.SimpleBuiltVariantPlatform,
      variant_platforms,
      Keyword.merge(opts,
        on_conflict: {:replace, [:product_code, :variant_code]},
        conflict_target: [:simple_built_variant_id, :platform_id]
      )
    )
  end

  def upsert(entities, opts \\ []) do
    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(entities, fn entity ->
             Pczone.Platform.new_changeset(entity) |> Pczone.Helpers.get_changeset_changes()
           end) do
      Repo.insert_all_2(
        Pczone.Platform,
        list,
        Keyword.merge(opts, on_conflict: {:replace, [:name]}, conflict_target: [:code])
      )
    end
  end

  def upsert_simple_built_platforms(platform_id, path, opts \\ []) do
    list =
      path
      |> Xlsx.read_spreadsheet()
      |> Enum.reduce(
        [],
        fn
          %{"product_code" => product_code, "simple_built_code" => simple_built_code}, acc ->
            acc ++ [%{product_code: product_code, simple_built_code: simple_built_code}]

          _, acc ->
            acc
        end
      )

    simple_built_codes = Enum.map(list, & &1.simple_built_code)

    simple_builts_map =
      from(b in SimpleBuilt, where: b.code in ^simple_built_codes, select: {b.code, b.id})
      |> Repo.all()
      |> Enum.into(%{})

    list =
      Enum.map(list, fn %{product_code: product_code, simple_built_code: simple_built_code} ->
        %{
          platform_id: platform_id,
          simple_built_id: simple_builts_map[simple_built_code],
          product_code: product_code
        }
      end)

    Repo.insert_all_2(
      Pczone.SimpleBuiltPlatform,
      list,
      [
        on_conflict: {:replace, [:product_code]},
        conflict_target: [:simple_built_id, :platform_id]
      ] ++ opts
    )
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

  def make_pricing_workbook(platform = %{rate: rate}) do
    headers = [
      [
        "et_title_product_id",
        "et_title_product_name",
        "et_title_variation_id",
        "et_title_variation_name",
        "et_title_parent_sku",
        "et_title_variation_sku",
        "et_title_variation_price",
        "et_title_variation_stock",
        "et_title_reason"
      ],
      ["sales_info", "220408_floatingstock"],
      [
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        "Giá của sản phẩm đắt nhất chia cho giá của giới hạn sản phẩm rẻ nhất: 5",
        nil
      ],
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
    ]

    rows =
      Repo.all(
        from v in Pczone.SimpleBuiltVariant,
          join: b in Pczone.SimpleBuilt,
          on: v.simple_built_id == b.id,
          join: bp in Pczone.SimpleBuiltPlatform,
          on: bp.simple_built_id == b.id,
          join: vp in Pczone.SimpleBuiltVariantPlatform,
          on: v.id == vp.simple_built_variant_id,
          where: vp.platform_id == ^platform.id,
          select: [
            bp.product_code,
            b.name,
            vp.variant_code,
            v.name,
            "",
            "",
            fragment("(?::decimal * ?)::integer", v.total, ^rate),
            99
          ]
      )

    %Workbook{
      sheets: [
        %Sheet{
          name: "Sheet1",
          rows: headers ++ rows
        }
      ]
    }
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
        from(vp in SimpleBuiltVariantPlatform,
          preload: [simple_built_variant: [:simple_built]],
          where: not is_nil(vp.variant_code)
        )
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

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
