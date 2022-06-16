defmodule PcZone.ScrapingData do
  def list(collection, attrs \\ %{})

  def list(
        collection,
        %Dew.Filter{
          filter: filter,
          paging: _paging,
          selection: _selection,
          order_by: _order_by
        } = params
      ) do
    opts = parse_opts(params)

    with {:ok, total_entities} <- Mongo.count(:mongo, collection, filter) do
      cursor = Mongo.find(:mongo, collection, filter, opts)

      entities =
        Enum.map(cursor, fn %{"_id" => id, "url" => url} = data ->
          %{
            id: BSON.ObjectId.encode!(id),
            url: url,
            data: Map.drop(data, ["_id", "url"])
          }
        end)

      page = Keyword.get(opts, :page)
      page_size = Keyword.get(opts, :limit)

      paging = %{
        page: page,
        page_size: page_size,
        total_entities: total_entities,
        total_pages: ceil(total_entities / page_size)
      }

      %{
        entities: entities,
        paging: paging
      }
    end
  end

  def list(collection, attrs = %{}), do: list(collection, struct(Dew.Filter, attrs))

  defp parse_opts(%{paging: paging}) do
    page = Map.get(paging, :page, 1)
    page_size = Map.get(paging, :page_size, 24)

    [
      page: page,
      skip: (page - 1) * page_size,
      limit: page_size
    ]
  end
end
