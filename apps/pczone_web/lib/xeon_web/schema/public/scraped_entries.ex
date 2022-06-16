defmodule PcZoneWeb.Schema.ScrapedEntries do
  use Absinthe.Schema.Notation

  object :scraped_entry do
    field :id, non_null(:id)
    field :url, non_null(:string)
    field :data, non_null(:json)
  end

  object :scraped_entry_list_result do
    field :entities, non_null(list_of(non_null(:scraped_entry)))
    field :paging, non_null(:paging)
  end

  object :scraped_entry_queries do
    field :scraped_entries, non_null(:scraped_entry_list_result) do
      arg :collection, non_null(:string)
      arg :filter, non_null(:json)
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn %{collection: collection} = args, _info ->
        {:ok, PcZone.ScrapingData.list(collection, args)}
      end)
    end
  end
end
