defmodule Pczone.SimpleBuiltVariants do
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias Elixlsx.{Sheet, Workbook}
  alias Pczone.Repo

  def get(id) do
    Repo.get(Pczone.SimpleBuiltVariant, id)
  end

  def get_by_code(code) do
    Repo.one(from Pczone.SimpleBuiltVariant, where: [code: ^code], limit: 1)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.SimpleBuiltVariant
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def export_csv(filter \\ %{}) do
    date = Date.utc_today() |> Calendar.strftime("%Y-%m")
    now = DateTime.utc_now() |> DateTime.to_unix()
    name = "simple-built-variants-#{now}"
    type = "xlsx"
    path = "#{date}/#{name}.#{type}"
    absolute_path = Path.join(Pczone.Reports.get_report_dir(), path)

    with {:ok, _} <- generate_report(filter) |> Elixlsx.write_to(absolute_path) do
      %{size: size} = File.stat!(absolute_path)

      %{
        name: name,
        type: type,
        category: "simple-built-variant",
        path: path,
        size: size
      }
      |> Pczone.Report.new_changeset()
      |> Repo.insert()
    end
  end

  def generate_report(filter \\ %{}) do
    rows =
      Repo.all(
        from v in Pczone.SimpleBuiltVariant,
          join: sb in Pczone.SimpleBuilt,
          on: sb.id == v.simple_built_id,
          where: ^parse_filter(filter),
          # preload: [:simple_built],
          select: %{
            id: v.id,
            name: sb.name,
            option_values: v.option_values,
            total: v.total
          }
      )
      |> Enum.map(fn %{id: id, name: name, total: total, option_values: option_values} ->
        [id, name, "", "", Enum.join(option_values, "; "), total, 99]
      end)

    %Workbook{
      sheets: [
        %Sheet{
          name: "Products",
          rows:
            [
              [
                # "Id",
                # "Tên Sản phẩm",
                # "Mã Sản phẩm",
                # "Mã Phân loại",
                # "Tên phân loại",
                # "Giá",
                # "Số lượng"
                "id",
                "product_name",
                "product_code",
                "variant_code",
                "option_values",
                "price",
                "stock"
              ]
            ] ++ rows
        }
      ]
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
