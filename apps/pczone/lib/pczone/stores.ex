defmodule Pczone.Stores do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Elixlsx.{Sheet, Workbook}

  alias Pczone.{
    Repo,
    Store,
    BuiltTemplateStore,
    Built,
    BuiltStore,
    Xlsx
  }

  def get(id) do
    Repo.get(Store, id)
  end

  def get_by_code(code) do
    Repo.one(from(Store, where: [code: ^code], limit: 1))
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Store
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create(params) do
    params
    |> Pczone.Store.new_changeset()
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

  def read_product_variants("lazada", path) do
    with [{:ok, sheet} | _] <- Xlsxir.multi_extract(path),
         list <-
           Xlsxir.get_list(sheet) |> Xlsx.spreadsheet_to_list() do
      Enum.map(list, fn %{
                          "tr(s-wb-product@md5key)" => variant_code,
                          "Product ID" => product_code,
                          "sku.skuId" => sku,
                          "Lazada SKU" => lazada_sku,
                          "Variations Combo" => variant_name
                        } ->
        %{
          product_code: product_code,
          variant_name: variant_name,
          variant_code: "#{sku}:#{lazada_sku}:#{variant_code}"
        }
      end)
      |> Enum.filter(&(&1.product_code != nil))
      |> Enum.drop(3)
    end
  end

  @doc """
  Read an xlsx file exported from store.
  Extract variant_code by product_code & variant_name.
  Then upsert all to built_store.
  """
  def upsert_built_stores(store, path, opts \\ [])

  def upsert_built_stores(
        %Store{id: store_id, code: store_code},
        path,
        opts
      ) do
    list = read_product_variants(store_code, path)

    product_codes =
      list
      |> Enum.map(& &1.product_code)
      |> Enum.uniq()

    product_codes_map_by_built_template_id =
      Repo.all(
        from p in BuiltTemplateStore,
          where: p.product_code in ^product_codes,
          select: {p.built_template_id, p.product_code}
      )
      |> Enum.into(%{})

    built_template_ids = Map.keys(product_codes_map_by_built_template_id)

    builts = Repo.all(from v in Built, where: v.built_template_id in ^built_template_ids)

    built_stores =
      builts
      |> Enum.map(fn %Built{
                       id: built_id,
                       name: name,
                       built_template_id: built_template_id
                     } ->
        product_code = product_codes_map_by_built_template_id[built_template_id]

        variant_code =
          case Enum.find(list, &(&1.product_code == product_code && &1.variant_name == name)) do
            %{variant_code: variant_code} -> variant_code
            _ -> nil
          end

        %{
          store_id: store_id,
          built_id: built_id,
          product_code: product_code,
          variant_code: variant_code
        }
      end)
      |> Enum.filter(&(&1.variant_code != nil))

    Repo.insert_all_2(
      Pczone.BuiltStore,
      built_stores,
      Keyword.merge(opts,
        on_conflict: {:replace, [:product_code, :variant_code]},
        conflict_target: [:built_id, :store_id]
      )
    )
  end

  def upsert_built_stores(store_id, path, opts) do
    get(store_id) |> upsert_built_stores(path, opts)
  end

  def upsert(entities, opts \\ []) do
    with list = [_ | _] <-
           Pczone.Helpers.get_list_changset_changes(entities, fn entity ->
             Pczone.Store.new_changeset(entity) |> Pczone.Helpers.get_changeset_changes()
           end) do
      Repo.insert_all_2(
        Pczone.Store,
        list,
        Keyword.merge(opts, on_conflict: {:replace, [:name]}, conflict_target: [:code])
      )
    end
  end

  @doc """
  Upsert builts for a specific store
  """
  def upsert_builts(store_id, list) do
    list = list |> Enum.map(&parse_item(store_id, &1))

    Repo.insert_all_2(BuiltStore, list,
      conflict_target: [:store_id, :built_id],
      on_conflict: {:replace, [:product_code, :variant_code]}
    )
  end

  def read_store_builts(path) do
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

  def make_pricing_workbook(store = %{code: "shopee", rate: rate}) do
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
        from v in Pczone.Built,
          join: b in Pczone.BuiltTemplate,
          on: v.built_template_id == b.id,
          join: bp in Pczone.BuiltTemplateStore,
          on: bp.built_template_id == b.id,
          join: vp in Pczone.BuiltStore,
          on: v.id == vp.built_id,
          where: vp.store_id == ^store.id,
          select: [
            bp.product_code,
            b.name,
            vp.variant_code,
            v.name,
            "",
            "",
            fragment("(?::decimal * ?)::integer", v.price, ^rate),
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

  def make_pricing_workbook(store = %{code: "lazada", rate: rate}) do
    headers = [
      [
        "Product ID",
        "catId",
        "Tên sản phẩm",
        "currencyCode",
        "sku.skuId",
        "Variations Combo",
        "Lazada SKU",
        "status",
        "SpecialPrice",
        "SpecialPrice Start",
        "SpecialPrice End",
        "Giá",
        "SellerSku",
        "Kho hàng",
        "tr(s-wb-product@md5key)"
      ],
      [],
      [],
      []
    ]

    rows =
      Repo.all(
        from v in Pczone.Built,
          join: b in Pczone.BuiltTemplate,
          on: v.built_template_id == b.id,
          join: vp in Pczone.BuiltStore,
          on: v.id == vp.built_id,
          where: vp.store_id == ^store.id,
          select: [
            vp.product_code,
            b.name,
            v.name,
            fragment("(?::decimal * ?)::integer", v.price, ^rate),
            vp.variant_code
          ]
      )
      |> Enum.map(fn [product_code, product_name, variant_name, price, variant_code] ->
        [sku, lazada_sku, product_md5] = String.split(variant_code, ":")

        [
          product_code,
          "",
          product_name,
          "",
          sku,
          variant_name,
          lazada_sku,
          "active",
          "",
          "",
          "",
          price,
          "",
          99,
          product_md5
        ]
      end)

    %Workbook{
      sheets: [
        %Sheet{
          name: "Sheet1",
          rows: headers ++ rows
        }
      ]
    }
  end

  def make_pricing_workbook(store_id) do
    get(store_id) |> make_pricing_workbook()
  end

  def generate_store_pricing_report(store_id) do
    store = Repo.get(Store, store_id)
    date = Date.utc_today() |> Calendar.strftime("%Y-%m")
    now = DateTime.utc_now() |> DateTime.to_unix()
    name = "#{store.code}-product-pricing-#{now}"
    type = "xlsx"
    path = "#{date}/#{name}.#{type}"
    absolute_path = Path.join(Pczone.Reports.get_report_dir(), path)

    with {:ok, _} <- make_pricing_workbook(store) |> Elixlsx.write_to(absolute_path) do
      %{size: size} = File.stat!(absolute_path)

      %{
        name: name,
        type: type,
        category: "store-product-pricing",
        path: path,
        size: size
      }
      |> Pczone.Report.new_changeset()
      |> Repo.insert()
    end
  end

  # def make_store_pricing_workbook(%Store{rate: rate}) do
  #   rows =
  #     Repo.all(
  #       from(vp in BuiltStore,
  #         preload: [built: [:built_template]],
  #         where: not is_nil(vp.variant_code)
  #       )
  #     )
  #     |> Enum.map(fn %BuiltStore{
  #                      product_code: product_code,
  #                      variant_code: variant_code,
  #                      built: %Built{
  #                        built_template: built_template,
  #                        option_values: option_values,
  #                        total: total
  #                      }
  #                    } ->
  #       [
  #         # Mã Sản phẩm
  #         product_code,
  #         # Tên Sản phẩm
  #         built_template.name,
  #         # Mã Phân loại
  #         variant_code,
  #         # Tên phân loại
  #         Enum.join(option_values, "; "),
  #         # SKU Sản phẩm
  #         "",
  #         # SKU
  #         "",
  #         # Giá
  #         Decimal.mult(total, rate) |> Decimal.to_integer(),
  #         # Số lượng
  #         999
  #       ]
  #     end)

  #   %Workbook{
  #     sheets: [
  #       %Sheet{
  #         name: "Sheet1",
  #         rows:
  #           [
  #             [
  #               "Mã Sản phẩm",
  #               "Tên Sản phẩm",
  #               "Mã Phân loại",
  #               "Tên phân loại",
  #               "SKU Sản phẩm",
  #               "SKU",
  #               "Giá",
  #               "Số lượng"
  #             ]
  #           ] ++ rows
  #       }
  #     ]
  #   }
  # end

  # def make_store_pricing_workbook(store_id) do
  #   Repo.get(Store, store_id) |> make_store_pricing_workbook
  # end

  defp parse_item(store_id, %{
         "id" => built_id,
         "product_code" => product_code,
         "variant_code" => variant_code
       }) do
    %{
      store_id: store_id,
      built_id: built_id,
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
