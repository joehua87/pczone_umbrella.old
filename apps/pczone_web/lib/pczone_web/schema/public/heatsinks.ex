defmodule PczoneWeb.Schema.Heatsinks do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :heatsink do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :supported_types, non_null(list_of(non_null(:string)))
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :heatsink_filter_input do
    field :name, :string_filter_input
    field :brand_id, :id_filter_input
  end

  object :heatsink_list_result do
    field :entities, non_null(list_of(non_null(:heatsink)))
    field :paging, non_null(:paging)
  end

  object :heatsink_queries do
    field :heatsinks, non_null(:heatsink_list_result) do
      arg :filter, :heatsink_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Heatsinks.list()

        {:ok, list}
      end)
    end
  end

  object :heatsink_mutations do
    field :upsert_heatsinks, non_null(list_of(non_null(:heatsink))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Heatsinks.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
