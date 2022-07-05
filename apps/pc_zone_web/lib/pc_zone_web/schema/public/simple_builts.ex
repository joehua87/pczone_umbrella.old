defmodule PcZoneWeb.Schema.SimpleBuilts do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :simple_built_processor do
    field :processor_id, non_null(:id)
    field :processor_product_id, non_null(:id)
    field :processor_label, non_null(:string)
    field :processor_quantity, non_null(:integer)
    field :gpu_id, :id
    field :gpu_product_id, :id
    field :gpu_label, non_null(:string)
    field :gpu_quantity, :integer

    field :processor,
          non_null(:processor),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :processor_product,
          non_null(:product),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :gpu,
          non_null(:gpu),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :gpu_product,
          non_null(:product),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  object :simple_built_memory do
    field :memory_id, non_null(:id)
    field :memory_product_id, non_null(:id)
    field :memory_quantity, non_null(:integer)
    field :label, non_null(:string)
    field :quantity, non_null(:integer)

    field :memory,
          non_null(:memory),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :memory_product,
          non_null(:product),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  object :simple_built_hard_drive do
    field :hard_drive_id, non_null(:id)
    field :hard_drive_product_id, non_null(:id)
    field :hard_drive_quantity, non_null(:integer)
    field :label, non_null(:string)
    field :quantity, non_null(:integer)

    field :hard_drive,
          non_null(:hard_drive),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :hard_drive_product,
          non_null(:product),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  object :simple_built do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :option_types, non_null(list_of(non_null(:string)))
    field :option_value_seperator, non_null(:string)
    field :barebone_id, non_null(:id)
    field :barebone_product_id, non_null(:id)

    field :barebone,
          non_null(:barebone),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :barebone_product,
          non_null(:product),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :processors,
          non_null(list_of(non_null(:simple_built_processor))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :memories,
          non_null(list_of(non_null(:simple_built_memory))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :hard_drives,
          non_null(list_of(non_null(:simple_built_hard_drive))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  input_object :simple_built_filter_input do
    field :name, :string_filter_input
  end

  input_object :simple_built_processor_input do
    # field :processor_product_id, non_null(:id)
    field :processor_product, non_null(:string)
    field :processor, :string
    field :processor_label, non_null(:string)
    field :processor_quantity, :integer
    # field :gpu_product_id, :id
    field :gpu_product, :string
    field :gpu, :string
    field :gpu_label, :string
    field :gpu_quantity, :integer
  end

  input_object :simple_built_memory_input do
    # field :memory_product_id, non_null(:id)
    field :memory_product, non_null(:string)
    field :memory, :string
    field :memory_quantity, :integer
    field :label, non_null(:string)
    field :quantity, :integer
  end

  input_object :simple_built_hard_drive_input do
    # field :hard_drive_product_id, non_null(:id)
    field :hard_drive_product, non_null(:string)
    field :hard_drive, :string
    field :hard_drive_quantity, :integer
    field :label, non_null(:string)
    field :quantity, :integer
  end

  input_object :create_simple_built_input do
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :option_types, non_null(list_of(non_null(:string)))
    field :option_value_seperator, :string
    # field :barebone_id, non_null(:id)
    field :barebone, non_null(:string)
    field :barebone_product, non_null(:string)
    field :processors, non_null(list_of(non_null(:simple_built_processor_input)))
    field :memories, non_null(list_of(non_null(:simple_built_memory_input)))
    field :hard_drives, non_null(list_of(non_null(:simple_built_hard_drive_input)))
  end

  object :simple_built_list_result do
    field :entities, non_null(list_of(non_null(:simple_built)))
    field :paging, non_null(:paging)
  end

  object :simple_built_queries do
    field :simple_builts, non_null(:simple_built_list_result) do
      arg :filter, :simple_built_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> PcZone.SimpleBuilts.list()

        {:ok, list}
      end)
    end
  end

  object :simple_built_mutations do
    field :create_simple_built, non_null(:simple_built) do
      # arg :data, non_null(:create_simple_built_input)
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        PcZone.SimpleBuilts.upsert(data)
      end)
    end

    field :generate_simple_built_variants, non_null(:json) do
      # arg :data, non_null(:create_simple_built_input)
      arg :code, non_null(:string)

      resolve(fn %{code: code}, _info ->
        {:ok, PcZone.SimpleBuilts.generate_variants(code) |> IO.inspect()}
      end)
    end
  end
end
