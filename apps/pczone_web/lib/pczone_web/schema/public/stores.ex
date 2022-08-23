defmodule PczoneWeb.Schema.Stores do
  use Absinthe.Schema.Notation

  object :store do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :rate, non_null(:decimal)
  end

  input_object :store_filter_input do
    field :name, :string_filter_input
  end

  object :store_list_result do
    field :entities, non_null(list_of(non_null(:store)))
    field :paging, non_null(:paging)
  end

  object :store_queries do
    field :stores, non_null(:store_list_result) do
      arg :filter, :store_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Stores.list()

        {:ok, list}
      end)
    end
  end

  object :store_mutations do
    field :generate_store_pricing_report, non_null(:report) do
      arg :store_id, non_null(:id)

      resolve fn %{store_id: store_id}, _info ->
        Pczone.Stores.generate_store_pricing_report(store_id)
      end
    end

    field :upsert_stores, non_null(list_of(non_null(:store))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Stores.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
