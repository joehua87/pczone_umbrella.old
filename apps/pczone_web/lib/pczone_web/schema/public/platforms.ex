defmodule PczoneWeb.Schema.Platforms do
  use Absinthe.Schema.Notation

  object :platform do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :rate, non_null(:decimal)
  end

  input_object :platform_filter_input do
    field :name, :string_filter_input
  end

  object :platform_list_result do
    field :entities, non_null(list_of(non_null(:platform)))
    field :paging, non_null(:paging)
  end

  object :platform_queries do
    field :platforms, non_null(:platform_list_result) do
      arg :filter, :platform_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Platforms.list()

        {:ok, list}
      end)
    end
  end

  object :platform_mutations do
    field :upsert_platforms, non_null(list_of(non_null(:platform))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Platforms.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
