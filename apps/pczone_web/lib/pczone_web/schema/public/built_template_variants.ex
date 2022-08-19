defmodule PczoneWeb.Schema.BuiltTemplateVariants do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers
  alias PczoneWeb.Dataloader

  object :built_template_variant_store do
    field :store_id, non_null(:id)
    field :built_template_variant_id, non_null(:id)
    field :store, non_null(:store), resolve: dataloader(Dataloader)

    field :built_template_variant, non_null(:built_template_variant),
      resolve: dataloader(Dataloader)

    field :product_code, non_null(:string)
    field :variant_code, non_null(:string)
  end

  object :built_template_variant do
    field :id, non_null(:id)
    field :built_template_id, non_null(:id)
    field :built_template, non_null(:built_template), resolve: dataloader(Dataloader)
    field :barebone_id, non_null(:id)
    field :barebone, non_null(:barebone), resolve: dataloader(Dataloader)
    field :barebone_product_id, non_null(:id)
    field :barebone_product, non_null(:product), resolve: dataloader(Dataloader)
    field :barebone_price, non_null(:integer)
    field :processor_id, non_null(:id)
    field :processor, non_null(:processor), resolve: dataloader(Dataloader)
    field :processor_product_id, non_null(:id)
    field :processor_product, non_null(:product), resolve: dataloader(Dataloader)
    field :processor_price, non_null(:integer)
    field :processor_quantity, non_null(:integer)
    field :processor_amount, non_null(:integer)
    field :gpu_id, :id
    field :gpu, :gpu, resolve: dataloader(Dataloader)
    field :gpu_product_id, :id
    field :gpu_product, :product, resolve: dataloader(Dataloader)
    field :gpu_price, :integer
    field :gpu_quantity, :integer
    field :gpu_amount, :integer
    field :memory_id, :id
    field :memory, :memory, resolve: dataloader(Dataloader)
    field :memory_product_id, :id
    field :memory_product, :product, resolve: dataloader(Dataloader)
    field :memory_price, :integer
    field :memory_quantity, :integer
    field :memory_amount, :integer
    field :hard_drive_id, :id
    field :hard_drive, :hard_drive, resolve: dataloader(Dataloader)
    field :hard_drive_product_id, :id
    field :hard_drive_product, :product, resolve: dataloader(Dataloader)
    field :hard_drive_price, :integer
    field :hard_drive_quantity, :integer
    field :hard_drive_amount, :integer
    field :option_values, non_null(list_of(non_null(:string)))
    field :total, non_null(:integer)
    field :config, non_null(:json)

    field :stores,
          non_null(list_of(non_null(:built_template_variant_store))),
          resolve: dataloader(Dataloader)
  end

  input_object :built_template_variant_filter_input do
    field :built_template_id, :id_filter_input
    field :name, :string_filter_input
    field :total, :integer_filter_input
  end

  object :built_template_variant_list_result do
    field :entities, non_null(list_of(non_null(:built_template_variant)))
    field :paging, non_null(:paging)
  end

  object :built_template_variant_queries do
    field :built_template_variants, non_null(:built_template_variant_list_result) do
      arg :filter, :built_template_variant_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.BuiltTemplateVariants.list()

        {:ok, list}
      end)
    end
  end

  object :built_template_variant_mutations do
    field :generate_store_pricing_report, non_null(:report) do
      arg :store_id, non_null(:id)

      resolve fn %{store_id: store_id}, _info ->
        Pczone.Stores.generate_store_pricing_report(store_id)
      end
    end

    field :generate_built_template_variants_report, non_null(:report) do
      arg :filter, :built_template_variant_filter_input

      resolve fn args, _info ->
        filter = Map.get(args, :filter, %{})
        Pczone.BuiltTemplateVariants.export_csv(filter)
      end
    end
  end
end
