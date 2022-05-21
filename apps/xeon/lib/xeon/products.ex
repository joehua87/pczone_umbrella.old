defmodule Xeon.Products do
  require Logger
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias Xeon.{Repo, Product}

  def get_by_sku(sku) do
    Repo.one(from x in Product, where: x.sku == ^sku, limit: 1)
  end

  def get(id) do
    Repo.get(Product, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Product
    |> where(^parse_filter(filter))
    |> select_fields(selection)
    |> sort_by(order_by, ["title"])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(entities, opts \\ []) when is_list(entities) do
    entities =
      ensure_products("motherboard", entities) ++
        ensure_products("barebone", entities) ++
        ensure_products("processor", entities) ++
        ensure_products("memory", entities) ++
        ensure_products("hard_drive", entities) ++
        ensure_products("gpu", entities)

    Repo.insert_all(
      Product,
      entities,
      [on_conflict: :replace_all, conflict_target: [:sku]] ++ opts
    )
  end

  def ensure_products(kind, entities) do
    codes =
      entities
      |> Enum.filter(&(&1["kind"] == kind))
      |> Enum.map(& &1["ref_code"])

    queryable =
      %{
        "processor" => Xeon.Processor,
        "motherboard" => Xeon.Motherboard,
        "memory" => Xeon.Memory,
        "barebone" => Xeon.Barebone,
        "gpu" => Xeon.Gpu,
        "hard_drive" => Xeon.HardDrive
      }[kind]

    map =
      Repo.all(
        from(p in queryable,
          where: p.code in ^codes,
          select: {p.code, %{id: p.id, slug: p.slug, title: p.name}}
        )
      )
      |> Enum.into(%{})

    entities
    |> Enum.map(fn
      %{"ref_code" => code, "condition" => condition, "sale_price" => sale_price} = params ->
        sale_price = ensure_price(sale_price)

        list_price =
          case params do
            %{"list_price" => list_price} -> ensure_price(list_price)
            _ -> nil
          end

        percentage_off =
          case list_price do
            nil -> 0
            _ -> (list_price - sale_price) / sale_price
          end

        case map[code] do
          nil ->
            nil

          %{id: id, slug: slug, title: title} ->
            params
            |> Map.merge(%{
              "slug" => get_slug(params) || Slug.slugify("#{slug} #{condition}"),
              "title" => get_title(params) || "#{title} (#{condition})",
              "sale_price" => sale_price,
              "percentage_off" => percentage_off
            })
            |> Map.put("#{kind}_id", id)
            |> Xeon.Product.new_changeset()
            |> Xeon.Helpers.get_changeset_changes()
        end

      _ ->
        nil
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def get_title(%{"title" => title}), do: title
  def get_title(_), do: nil

  def get_slug(%{"slug" => slug}), do: slug
  def get_slug(_), do: nil

  def ensure_price(price) do
    price |> String.replace("_", "") |> String.to_integer()
  end

  def create(params) do
    params |> Product.new_changeset() |> Repo.insert()
  end

  def update(%{id: id} = params) do
    params = Enum.filter(params, fn {_key, value} -> value != nil end) |> Enum.into(%{})
    get(id) |> Product.changeset(params) |> Repo.update()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :id -> parse_id_filter(acc, field, value)
        :title -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
