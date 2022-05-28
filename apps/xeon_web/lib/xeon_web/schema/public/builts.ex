defmodule XeonWeb.Schema.Builts do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias Xeon.Builts

  object :built_psu do
    field :built_id, non_null(:id)
    field :psu_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :psu,
          non_null(:psu),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :quantity, non_null(:integer)
  end

  object :built_extension_device do
    field :built_id, non_null(:id)
    field :extension_device_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :extension_device,
          non_null(:extension_device),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :slot, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :built_processor do
    field :built_id, non_null(:id)
    field :extension_device_id, :id
    field :processor_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :extension_device,
          :extension_device,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :processor,
          non_null(:processor),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :slot, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :built_memory do
    field :built_id, non_null(:id)
    field :extension_device_id, :id
    field :memory_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :extension_device,
          :extension_device,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :memory,
          non_null(:memory),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :slot, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :built_hard_drive do
    field :built_id, non_null(:id)
    field :extension_device_id, :id
    field :hard_drive_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :extension_device,
          :extension_device,
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :hard_drive,
          non_null(:hard_drive),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :slot, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :built_gpu do
    field :built_id, non_null(:id)
    field :gpu_id, non_null(:id)
    field :product_id, non_null(:id)

    field :built,
          non_null(:built),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :gpu,
          non_null(:gpu),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :product,
          non_null(:product),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)

    field :slot, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :built do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :barebone_id, :id
    field :motherboard_id, :id
    field :chassis_id, :id
    field :barebone, :barebone
    field :motherboard, :motherboard
    field :chassis, :chassis
    field :built_psus, non_null(list_of(non_null(:built_psu)))
    field :built_extension_devices, non_null(list_of(non_null(:built_extension_device)))
    field :built_processors, non_null(list_of(non_null(:built_processor)))
    field :built_memories, non_null(list_of(non_null(:built_memory)))
    field :built_hard_drives, non_null(list_of(non_null(:built_hard_drive)))
    field :built_gpus, non_null(list_of(non_null(:built_gpu)))
  end

  input_object :built_filter_input do
    field :name, :string_filter_input
  end

  object :built_list_result do
    field :entities, non_null(list_of(non_null(:built)))
    field :paging, non_null(:paging)
  end

  input_object :built_psu_input do
    field :psu_id, non_null(:id)
    field :product_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :built_processor_input do
    field :processor_id, non_null(:id)
    field :product_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :built_memory_input do
    field :memory_id, non_null(:id)
    field :product_id, non_null(:id)
    field :slot_type, non_null(:string)
    field :quantity, non_null(:integer)
  end

  input_object :built_hard_drive_input do
    field :hard_drive_id, non_null(:id)
    field :product_id, non_null(:id)
    field :slot_type, non_null(:string)
    field :quantity, non_null(:integer)
  end

  input_object :built_gpu_input do
    field :gpu_id, non_null(:id)
    field :product_id, non_null(:id)
    field :slot_type, non_null(:string)
    field :quantity, non_null(:integer)
  end

  input_object :create_built_input do
    field :name, non_null(:string)
    field :barebone_id, :id
    field :chassis_id, :id
    field :motherboard_id, :id
    field :processors, non_null(list_of(non_null(:built_processor_input)))
    field :memories, non_null(list_of(non_null(:built_memory_input)))
    field :hard_drives, non_null(list_of(non_null(:built_hard_drive_input)))
    field :gpus, non_null(list_of(non_null(:built_gpu_input)))
  end

  object :built_queries do
    field :builts, non_null(:built_list_result) do
      arg :filter, :built_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: XeonWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Xeon.Builts.list()

        {:ok, list}
      end)
    end

    field :processors_for_built, non_null(list_of(non_null(:processor))) do
      arg :motherboard_id, non_null(:id)

      resolve fn %{motherboard_id: motherboard_id}, _info ->
        with entities when is_list(entities) <- Builts.get_processors(motherboard_id) do
          {:ok, entities}
        end
      end
    end

    field :memories_for_built, non_null(list_of(non_null(:memory))) do
      arg :motherboard_id, non_null(:id)

      resolve fn %{motherboard_id: motherboard_id}, _info ->
        with entities when is_list(entities) <- Builts.get_memories(motherboard_id) do
          {:ok, entities}
        end
      end
    end
  end

  object :built_mutations do
    field :create_built, non_null(:built) do
      arg :data, non_null(:create_built_input)

      resolve(fn %{data: data}, _info ->
        Builts.create(data)
      end)
    end
  end
end
