defmodule PcZoneWeb.Schema.Chipsets do
  use Absinthe.Schema.Notation
  alias PcZone.Chipsets

  object :chipset do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :code, non_null(:string)
    field :code_name, non_null(:string)
    field :name, non_null(:string)
    field :launch_date, non_null(:string)
    field :collection_name, non_null(:string)
    field :vertical_segment, non_null(:string)
    field :status, non_null(:string)
    field :processors, non_null(list_of(non_null(:processor)))
  end

  input_object :chipset_filter_input do
    field :id, :id_filter_input
    field :name, :string_filter_input
  end

  object :chipset_list_result do
    field :entities, non_null(list_of(non_null(:chipset)))
    field :paging, non_null(:paging)
  end

  object :chipset_queries do
    field :chipsets, non_null(:chipset_list_result) do
      arg :filter, :chipset_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Chipsets.list()

        {:ok, list}
      end)
    end
  end

  input_object :create_chipset_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :path, non_null(:string)
  end

  object :chipset_mutations do
    field :upsert_chipsets, non_null(list_of(non_null(:chipset))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {_, result} <- PcZone.Chipsets.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
