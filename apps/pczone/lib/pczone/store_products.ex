defmodule Pczone.StoreProducts do
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  alias Pczone.Repo

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.StoreProduct
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(store_id) when is_bitstring(store_id) do
    # TODO: Get data from store code
    with %{merchant_id: store_code} <- Pczone.Repo.get(Pczone.Store, store_id),
         list <- Pczone.Scraper.Shopee.get_all_products(store_code) do
      upsert(store_id, list)
    end
  end

  def upsert(store_id, list, opts \\ []) do
    entities = Enum.map(list, &parse_list_item(&1, store_id: store_id))

    Repo.insert_all(
      Pczone.StoreProduct,
      entities,
      [
        on_conflict: {:replace, [:name, :options, :images, :sold, :stats, :updated_at]},
        conflict_target: [:store_id, :product_code]
      ] ++ opts
    )
  end

  def update(store_product_id, data) do
    %{id: id, store_id: store_id} =
      store_product = Repo.get(Pczone.StoreProduct, store_product_id)

    %{
      description: description,
      variants: variants
    } = parse_detail_item(data, store_product_id: id, store_id: store_id)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Ecto.Changeset.change(store_product, description: description))
    |> Ecto.Multi.insert_all(:variants, Pczone.StoreVariant, variants)
    |> Repo.transaction()
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :store_id -> parse_id_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end

  defp parse_detail_item(
         %{
           "data" => %{
             "id" => product_code,
             "model_list" => model_list,
             "description" => description
           }
         },
         store_product_id: store_product_id,
         store_id: store_id
       ) do
    now = DateTime.utc_now()

    variants =
      Enum.map(model_list, fn %{"id" => variant_code, "name" => name} ->
        %{
          store_product_id: store_product_id,
          store_id: store_id,
          product_code: "#{product_code}",
          variant_code: "#{variant_code}",
          name: name,
          inserted_at: now,
          updated_at: now
        }
      end)

    %{
      description: description,
      variants: variants
    }
  end

  defp parse_list_item(
         %{
           "itemid" => product_code,
           "item_basic" => %{
             "name" => name,
             "images" => images,
             "historical_sold" => sold,
             "cmt_count" => comment_count,
             "liked_count" => like_count,
             "ctime" => created_at,
             "tier_variations" => options
           }
         },
         store_id: store_id
       ) do
    now = DateTime.utc_now()

    %{
      store_id: store_id,
      product_code: "#{product_code}",
      name: name,
      options: parse_options(options),
      images: parse_images(images),
      sold: sold,
      stats: %{
        "comment_count" => comment_count,
        "like_count" => like_count
      },
      created_at: DateTime.from_unix!(created_at),
      inserted_at: now,
      updated_at: now
    }
  end

  defp parse_images(list) do
    Enum.map(list, fn id ->
      %Pczone.EmbeddedMedium{id: id}
    end)
  end

  defp parse_options(list) do
    Enum.map(list, fn %{"name" => name, "options" => values} ->
      %Pczone.ProductOption{
        name: name,
        values: values
      }
    end)
  end
end
