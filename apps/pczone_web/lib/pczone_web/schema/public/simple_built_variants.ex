defmodule PczoneWeb.Schema.SimpleBuiltVariants do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers

  object :simple_built_variant_platform do
    field :platform_id, non_null(:id)
    field :simple_built_variant_id, non_null(:id)
    field :platform, non_null(:platform)
    field :simple_built_variant, non_null(:simple_built_variant)
    field :product_code, non_null(:string)
    field :variant_code, non_null(:string)
  end

  object :simple_built_variant do
    field :id, non_null(:id)
    field :simple_built_id, non_null(:id)
    field :simple_built, non_null(:simple_built), resolve: dataloader(PczoneWeb.Dataloader)
    field :barebone_id, non_null(:id)
    field :barebone, non_null(:barebone), resolve: dataloader(PczoneWeb.Dataloader)
    field :barebone_product_id, non_null(:id)
    field :barebone_product, non_null(:product), resolve: dataloader(PczoneWeb.Dataloader)
    field :barebone_price, non_null(:integer)
    field :processor_id, non_null(:id)
    field :processor, non_null(:processor), resolve: dataloader(PczoneWeb.Dataloader)
    field :processor_product_id, non_null(:id)
    field :processor_product, non_null(:product), resolve: dataloader(PczoneWeb.Dataloader)
    field :processor_price, non_null(:integer)
    field :processor_quantity, non_null(:integer)
    field :processor_amount, non_null(:integer)
    field :gpu_id, :id
    field :gpu, :gpu, resolve: dataloader(PczoneWeb.Dataloader)
    field :gpu_product_id, :id
    field :gpu_product, :product, resolve: dataloader(PczoneWeb.Dataloader)
    field :gpu_price, :integer
    field :gpu_quantity, :integer
    field :gpu_amount, :integer
    field :memory_id, :id
    field :memory, :memory, resolve: dataloader(PczoneWeb.Dataloader)
    field :memory_product_id, :id
    field :memory_product, :product, resolve: dataloader(PczoneWeb.Dataloader)
    field :memory_price, :integer
    field :memory_quantity, :integer
    field :memory_amount, :integer
    field :hard_drive_id, :id
    field :hard_drive, :hard_drive, resolve: dataloader(PczoneWeb.Dataloader)
    field :hard_drive_product_id, :id
    field :hard_drive_product, :product, resolve: dataloader(PczoneWeb.Dataloader)
    field :hard_drive_price, :integer
    field :hard_drive_quantity, :integer
    field :hard_drive_amount, :integer
    field :option_values, non_null(list_of(non_null(:string)))
    field :total, non_null(:integer)
    field :config, non_null(:json)

    field :platforms,
          non_null(list_of(non_null(:simple_built_variant_platform))),
          resolve: dataloader(PczoneWeb.Dataloader)
  end

  input_object :simple_built_variant_filter_input do
    field :name, :string_filter_input
  end

  object :simple_built_variant_list_result do
    field :entities, non_null(list_of(non_null(:simple_built_variant)))
    field :paging, non_null(:paging)
  end

  object :simple_built_variant_queries do
    field :simple_built_variants, non_null(:simple_built_variant_list_result) do
      arg :filter, :simple_built_variant_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.SimpleBuiltVariants.list()

        {:ok, list}
      end)
    end
  end

  object :simple_built_variant_mutations do
    field :generate_simple_built_variants_report, non_null(:report) do
      arg :filter, :simple_built_variant_filter_input

      resolve fn args, _info ->
        filter = Map.get(args, :filter, %{})
        Pczone.SimpleBuiltVariants.export_csv(filter)
      end
    end
  end
end
