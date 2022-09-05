defmodule PczoneWeb.Schema.Brands do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias PczoneWeb.Dataloader

  object :brand do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :post, :post, resolve: Helpers.dataloader(Dataloader)
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
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Brands.list()

        {:ok, list}
      end)
    end
  end

  object :brand_mutations do
    field :create_brand_post, non_null(:post) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        Pczone.Brands.create_post(id)
      end)
    end

    field :upsert_brands, non_null(list_of(non_null(:brand))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Brands.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
