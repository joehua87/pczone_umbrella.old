defmodule XeonWeb.Schema.Processors do
  use Absinthe.Schema.Notation

  alias Xeon.Processors

  object :attribute_item do
    field :label, non_null(:string)
    field :value, :string
  end

  object :attribute_group do
    field :title, non_null(:string)
    field :items, non_null(list_of(non_null(:attribute_item)))
  end

  object :processor do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :sub, non_null(:string)
    field :collection_name, non_null(:string)
    field :launch_date, non_null(:string)
    field :status, non_null(:string)
    field :socket, :string
    field :case_temperature, :decimal
    field :lithography, :string
    field :base_frequency, :decimal
    field :tdp_up_base_frequency, :decimal
    field :tdp_down_base_frequency, :decimal
    field :max_turbo_frequency, :decimal
    field :tdp, :decimal
    field :tdp_up, :decimal
    field :tdp_down, :decimal
    field :cache_size, :decimal
    field :cores, :integer
    field :threads, :integer
    field :processor_graphics, :string
    field :url, :string
    field :memory_types, non_null(list_of(non_null(:string)))
    field :ecc_memory_supported, :boolean
    field :attributes, non_null(list_of(non_null(:attribute_group)))
  end

  input_object :processor_filter_input do
    field :id, :id_filter_input
    field :code, :string_filter_input
    field :display_name, :string_filter_input
  end

  object :processor_list_result do
    field :entities, non_null(list_of(non_null(:processor)))
    field :paging, non_null(:paging)
  end

  object :processor_queries do
    field :processors, non_null(:processor_list_result) do
      arg :filter, :processor_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: XeonWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Processors.list()

        {:ok, list}
      end)
    end

    field :processor, :processor do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Processors.get(id)}
      end)
    end

    field :processor_by, :processor do
      arg :filter, :processor_filter_input

      resolve(fn args, _info ->
        {:ok, Processors.get(args)}
      end)
    end
  end
end
