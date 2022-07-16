defmodule PcZoneWeb.Schema.Brands do
  use Absinthe.Schema.Notation

  object :brand do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)
  end

  input_object :brand_filter_input do
    field :name, :string_filter_input
  end

  object :brand_list_result do
    field :entities, non_null(list_of(non_null(:brand)))
    field :paging, non_null(:paging)
  end

  object :brand_queries do
    field :brands, non_null(:brand_list_result) do
      arg :filter, :brand_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> PcZone.Brands.list()

        {:ok, list}
      end)
    end
  end

  object :brand_mutations do
    field :upsert_brands, non_null(list_of(non_null(:brand))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- PcZone.Brands.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
