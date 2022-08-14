defmodule Pczone.Products do
  require Logger
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, Product, ComponentProduct}

  def get_by_code(code) do
    Repo.one(from x in Product, where: x.code == ^code, limit: 1)
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

  def upsert(entities, _opts \\ []) when is_list(entities) do
    entities =
      ensure_products("motherboard", entities) ++
        ensure_products("barebone", entities) ++
        ensure_products("processor", entities) ++
        ensure_products("memory", entities) ++
        ensure_products("hard_drive", entities) ++
        ensure_products("gpu", entities)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:products, fn _, _ ->
      product_fields = [
        :sku,
        :slug,
        :title,
        :condition,
        :component_type,
        :is_bundled,
        :sale_price,
        :percentage_off,
        :stock,
        :list_price,
        :cost
      ]

      products = Enum.map(entities, &Map.take(&1, [:code] ++ product_fields))

      Repo.insert_all_2(
        Product,
        products,
        on_conflict: {:replace, product_fields},
        conflict_target: [:code],
        returning: true
      )
    end)
    |> Ecto.Multi.run(:component_products, fn _, %{products: {_, products}} ->
      product_ids_map =
        products
        |> Enum.map(fn %{id: id, code: code} ->
          {code, id}
        end)
        |> Enum.into(%{})

      component_product_fields = [
        :type,
        :barebone_id,
        :motherboard_id,
        :processor_id,
        :memory_id,
        :gpu_id,
        :hard_drive_id,
        :psu_id,
        :chassis_id,
        :heatsink_id
      ]

      component_products =
        Enum.map(entities, fn %{code: code} = entity ->
          Map.put(entity, :product_id, product_ids_map[code])
        end)
        |> Enum.map(&Map.take(&1, [:product_id] ++ component_product_fields))

      Repo.insert_all_2(
        ComponentProduct,
        component_products,
        on_conflict: {:replace, component_product_fields},
        conflict_target: [:product_id],
        returning: true
      )
    end)
    |> Repo.transaction()
  end

  def ensure_products(type, entities) do
    codes =
      entities
      |> Enum.filter(&(&1["type"] == type))
      |> Enum.map(& &1["ref_code"])

    queryable =
      %{
        "processor" => Pczone.Processor,
        "motherboard" => Pczone.Motherboard,
        "memory" => Pczone.Memory,
        "barebone" => Pczone.Barebone,
        "gpu" => Pczone.Gpu,
        "hard_drive" => Pczone.HardDrive
      }[type]

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
        list_price = Map.get(params, "list_price") |> ensure_price()
        cost = Map.get(params, "cost") |> ensure_price()

        percentage_off =
          case list_price do
            nil -> 0
            _ -> (list_price - sale_price) / sale_price
          end

        case map[code] do
          nil ->
            nil

          %{id: id, slug: slug, title: title} ->
            product =
              %{
                "slug" => get_slug(params) || Slug.slugify("#{slug} #{condition}"),
                "title" => get_title(params) || "#{title} (#{condition})",
                "list_price" => list_price,
                "sale_price" => sale_price,
                "percentage_off" => percentage_off,
                "cost" => cost,
                "component_type" => type,
                "is_bundled" => false
              }
              |> Map.merge(params)
              |> Pczone.Product.new_changeset()
              |> Pczone.Helpers.get_changeset_changes()

            component_product =
              params
              |> Map.put("#{type}_id", id)
              |> Pczone.ComponentProduct.changes_changeset()
              |> Pczone.Helpers.get_changeset_changes()

            Map.merge(product, component_product)
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

  def ensure_price(price) when is_number(price), do: price
  def ensure_price(""), do: nil
  def ensure_price(nil), do: nil

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
        :condition -> parse_string_filter(acc, field, value)
        :component_type -> parse_string_filter(acc, field, value)
        :is_bundled -> parse_boolean_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
