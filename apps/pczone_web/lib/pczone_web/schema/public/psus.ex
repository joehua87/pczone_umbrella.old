defmodule PczoneWeb.Schema.Psus do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :psu do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :wattage, non_null(:integer)
    field :form_factor, non_null(:string)
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :psu_filter_input do
    field :name, :string_filter_input
    field :brand_id, :id_filter_input
  end

  object :psu_list_result do
    field :entities, non_null(list_of(non_null(:psu)))
    field :paging, non_null(:paging)
  end

  object :psu_queries do
    field :psus, non_null(:psu_list_result) do
      arg :filter, :psu_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Psus.list()

        {:ok, list}
      end)
    end
  end

  object :psu_mutations do
    field :upsert_psus, non_null(list_of(non_null(:psu))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Psus.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
