defmodule PcZoneWeb.Schema.Motherboards do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias PcZone.Motherboards

  object :memory_slot do
    field :processor_index, non_null(:integer)
    field :type, non_null(:string)
    field :supported_types, non_null(list_of(non_null(:string)))
    field :quantity, non_null(:integer)
  end

  object :sata_slot do
    field :processor_index, non_null(:integer)
    field :type, non_null(:string)
    field :supported_types, non_null(list_of(non_null(:string)))
    field :quantity, non_null(:integer)
  end

  object :m2_slot do
    field :processor_index, non_null(:integer)
    field :type, non_null(:string)
    field :supported_types, non_null(list_of(non_null(:string)))
    field :form_factors, non_null(list_of(non_null(:string)))
    field :quantity, non_null(:integer)
  end

  object :pci_slot do
    field :processor_index, non_null(:integer)
    field :type, non_null(:string)
    field :supported_types, non_null(list_of(non_null(:string)))
    field :quantity, non_null(:integer)
  end

  object :processor_slot do
    field :socket, :string
    field :heatsink_type, :string
    field :quantity, non_null(:integer)
  end

  object :motherboard do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :max_memory_capacity, non_null(:string)
    field :memory_slots, non_null(list_of(non_null(:memory_slot)))
    field :processor_slots, non_null(list_of(non_null(:processor_slot)))
    field :sata_slots, non_null(list_of(non_null(:sata_slot)))
    field :m2_slots, non_null(list_of(non_null(:m2_slot)))
    field :pci_slots, non_null(list_of(non_null(:pci_slot)))
    field :chipset_id, non_null(:id)

    field :chipset,
          non_null(:chipset),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :processors,
          non_null(list_of(non_null(:processor))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  input_object :motherboard_filter_input do
    field :id, :id_filter_input
    field :name, :string_filter_input
  end

  object :motherboard_list_result do
    field :entities, non_null(list_of(non_null(:motherboard)))
    field :paging, non_null(:paging)
  end

  object :motherboard_queries do
    field :motherboards, non_null(:motherboard_list_result) do
      arg :filter, :motherboard_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Motherboards.list()

        {:ok, list}
      end
    end

    field :motherboard, :motherboard do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Motherboards.get(id)}
      end)
    end

    field :motherboard_by, :motherboard do
      arg :filter, :motherboard_filter_input

      resolve(fn args, _info ->
        {:ok, Motherboards.get(args)}
      end)
    end
  end

  input_object :motherboard_processor_input do
    field :motherboard_id, non_null(:integer)
    field :processor_id, non_null(:integer)
  end

  input_object :motherboard_processors_input do
    field :motherboard_id, non_null(:integer)
    field :processor_ids, non_null(list_of(non_null(:integer)))
  end

  object :motherboard_mutations do
    field :upsert_motherboards, non_null(list_of(non_null(:motherboard))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- PcZone.Motherboards.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end

    field :add_motherboard_processor, non_null(:integer) do
      arg :data, non_null(:motherboard_processor_input)

      resolve(fn %{data: data}, _info ->
        with %{} <- Motherboards.add_processor(data) do
          {:ok, 1}
        end
      end)
    end

    field :remove_motherboard_processor, non_null(:integer) do
      arg :data, non_null(:motherboard_processor_input)

      resolve(fn %{data: data}, _info ->
        with %{} <- Motherboards.remove_processor(data) do
          {:ok, 1}
        end
      end)
    end

    field :update_motherboard_processors, non_null(:integer) do
      arg :data, non_null(:motherboard_processors_input)

      resolve(fn %{data: data}, _info ->
        with {updated, _} <- Motherboards.update_processors(data) do
          {:ok, updated}
        end
      end)
    end
  end
end
