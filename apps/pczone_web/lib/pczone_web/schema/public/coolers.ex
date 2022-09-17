defmodule PczoneWeb.Schema.Coolers do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :cooler do
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

  input_object :cooler_filter_input do
    field :name, :string_filter_input
    field :brand_id, :id_filter_input
  end

  object :cooler_list_result do
    field :entities, non_null(list_of(non_null(:cooler)))
    field :paging, non_null(:paging)
  end

  object :cooler_queries do
    field :coolers, non_null(:cooler_list_result) do
      arg :filter, :cooler_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Coolers.list()

        {:ok, list}
      end)
    end
  end

  object :cooler_mutations do
    field :upsert_coolers, non_null(list_of(non_null(:cooler))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Coolers.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
