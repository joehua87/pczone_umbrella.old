defmodule PczoneWeb.Schema.Chassises do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :hard_drive_slot do
    field :form_factor, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :chassis do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :form_factor, non_null(:string)
    field :psu_form_factors, non_null(list_of(non_null(:string)))
    field :hard_drive_slots, non_null(list_of(non_null(:hard_drive_slot)))
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :chassis_filter_input do
    field :code, :string_filter_input
    field :name, :string_filter_input
    field :brand_id, :id_filter_input
  end

  object :chassis_list_result do
    field :entities, non_null(list_of(non_null(:chassis)))
    field :paging, non_null(:paging)
  end

  object :chassis_queries do
    field :chassises, non_null(:chassis_list_result) do
      arg :filter, :chassis_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Chassises.list()

        {:ok, list}
      end)
    end
  end

  object :chassis_mutations do
    field :upsert_chassises, non_null(list_of(non_null(:chassis))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Pczone.Chassises.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
