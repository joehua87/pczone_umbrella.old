defmodule PczoneWeb.Schema.BuiltTemplates do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias Pczone.BuiltTemplates
  alias PczoneWeb.Dataloader

  object :built_template_processor do
    field :key, non_null(:string)
    field :processor_id, non_null(:id)
    field :processor_product_id, non_null(:id)
    field :processor_label, non_null(:string)
    field :processor_quantity, non_null(:integer)
    field :gpu_id, :id
    field :gpu_product_id, :id
    field :gpu_label, :string
    field :gpu_quantity, :integer
    field :processor, non_null(:processor), resolve: Helpers.dataloader(Dataloader)
    field :processor_product, non_null(:product), resolve: Helpers.dataloader(Dataloader)
    field :gpu, :gpu, resolve: Helpers.dataloader(Dataloader)
    field :gpu_product, :product, resolve: Helpers.dataloader(Dataloader)
  end

  object :built_template_memory do
    field :key, non_null(:string)
    field :memory_id, non_null(:id)
    field :memory_product_id, non_null(:id)
    field :label, non_null(:string)
    field :quantity, non_null(:integer)
    field :memory, non_null(:memory), resolve: Helpers.dataloader(Dataloader)
    field :memory_product, non_null(:product), resolve: Helpers.dataloader(Dataloader)
  end

  object :built_template_hard_drive do
    field :key, non_null(:string)
    field :hard_drive_id, non_null(:id)
    field :hard_drive_product_id, non_null(:id)
    field :label, non_null(:string)
    field :quantity, non_null(:integer)

    field :hard_drive,
          non_null(:hard_drive),
          resolve: Helpers.dataloader(Dataloader)

    field :hard_drive_product,
          non_null(:product),
          resolve: Helpers.dataloader(Dataloader)
  end

  object :built_template_store do
    field :built_template_id, non_null(:id)
    field :store_id, non_null(:id)
    field :built_template, non_null(:built_template), resolve: Helpers.dataloader(Dataloader)
    field :store, non_null(:store), resolve: Helpers.dataloader(Dataloader)
    field :product_code, non_null(:string)
    field :name, :string
  end

  object :built_template do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :option_types, non_null(list_of(non_null(:string)))
    field :option_value_seperator, non_null(:string)
    field :media, non_null(list_of(non_null(:embedded_medium)))
    field :barebone_id, non_null(:id)
    field :barebone_product_id, non_null(:id)
    field :barebone, non_null(:barebone), resolve: Helpers.dataloader(Dataloader)
    field :barebone_product, non_null(:product), resolve: Helpers.dataloader(Dataloader)
    field :post_id, :id
    field :post, :post, resolve: Helpers.dataloader(Dataloader)

    field :processors,
          non_null(list_of(non_null(:built_template_processor))),
          resolve: Helpers.dataloader(Dataloader)

    field :memories,
          non_null(list_of(non_null(:built_template_memory))),
          resolve: Helpers.dataloader(Dataloader)

    field :hard_drives,
          non_null(list_of(non_null(:built_template_hard_drive))),
          resolve: Helpers.dataloader(Dataloader)

    field :built_template_stores,
          non_null(list_of(non_null(:built_template_store))),
          resolve: Helpers.dataloader(Dataloader)

    field :builts,
          non_null(list_of(non_null(:built))),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :taxons,
          non_null(list_of(non_null(:taxon))),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  object :built_template_taxon do
    field :built_template_id, non_null(:id)
    field :taxonomy_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :built_template_filter_input do
    field :code, :string_filter_input
    field :name, :string_filter_input
    field :taxons, list_of(non_null(:taxon_filter_input))
  end

  input_object :built_template_processor_input do
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

  input_object :built_template_memory_input do
    # field :memory_product_id, non_null(:id)
    field :memory_product, non_null(:string)
    field :memory, :string
    field :label, non_null(:string)
    field :quantity, :integer
  end

  input_object :built_template_hard_drive_input do
    # field :hard_drive_product_id, non_null(:id)
    field :hard_drive_product, non_null(:string)
    field :hard_drive, :string
    field :label, non_null(:string)
    field :quantity, :integer
  end

  input_object :create_built_template_input do
    field :code, non_null(:string)
    field :name, non_null(:string)
    field :option_types, non_null(list_of(non_null(:string)))
    field :option_value_seperator, :string
    field :media, list_of(non_null(:embedded_medium_input))
    # field :barebone_id, non_null(:id)
    field :barebone, non_null(:string)
    field :barebone_product, non_null(:string)
    field :processors, non_null(list_of(non_null(:built_template_processor_input)))
    field :memories, non_null(list_of(non_null(:built_template_memory_input)))
    field :hard_drives, non_null(list_of(non_null(:built_template_hard_drive_input)))
  end

  input_object :update_built_template_input do
    field :media, list_of(non_null(:embedded_medium_input))
  end

  input_object :built_template_store_input do
    field :store_id, non_null(:id)
    field :built_template_id, non_null(:id)
    field :product_code, non_null(:string)
  end

  object :built_template_list_result do
    field :entities, non_null(list_of(non_null(:built_template)))
    field :paging, non_null(:paging)
  end

  object :built_template_queries do
    field :built_template, :built_template do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Pczone.BuiltTemplates.get(id)}
      end)
    end

    field :built_template_by_filter, :built_template do
      arg :filter, non_null(:built_template_filter_input)

      resolve(fn %{filter: filter}, _info ->
        {:ok, Pczone.BuiltTemplates.get(filter)}
      end)
    end

    field :built_templates, non_null(:built_template_list_result) do
      arg :filter, :built_template_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.BuiltTemplates.list()

        {:ok, list}
      end)
    end

    field :built_template_content, non_null(:string) do
      arg :built_template_id, non_null(:id)
      arg :template, non_null(:string)

      resolve(fn %{built_template_id: built_template_id, template: template}, _info ->
        {:ok, Pczone.BuiltTemplates.generate_content(built_template_id, template)}
      end)
    end
  end

  input_object :add_built_template_taxon_input do
    field :built_template_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :remove_built_template_taxon_input do
    field :built_template_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :add_built_template_taxonomies_input do
    field :built_template_id, non_null(:id)
    field :taxon_ids, non_null(list_of(non_null(:id)))
  end

  input_object :remove_built_template_taxonomies_input do
    field :built_template_id, non_null(:id)
    field :taxon_ids, non_null(list_of(non_null(:id)))
  end

  object :built_template_mutations do
    field :update_built_template, non_null(:built_template) do
      arg :id, non_null(:id)
      arg :data, non_null(:update_built_template_input)

      resolve(fn %{id: id, data: data}, _info ->
        BuiltTemplates.update(id, data)
      end)
    end

    field :create_built_template_post, non_null(:post) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        BuiltTemplates.create_post(id)
      end)
    end

    field :upsert_built_templates, non_null(list_of(non_null(:built_template))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        Pczone.BuiltTemplates.upsert(data)
      end)
    end

    field :remove_built_template_processors, non_null(:id) do
      arg :built_template_id, non_null(:id)

      resolve(fn %{built_template_id: built_template_id}, _info ->
        with {_, nil} <- Pczone.BuiltTemplates.remove_built_template_processors(built_template_id) do
          {:ok, built_template_id}
        end
      end)
    end

    field :remove_built_template_memories, non_null(:id) do
      arg :built_template_id, non_null(:id)

      resolve(fn %{built_template_id: built_template_id}, _info ->
        with {_, nil} <- Pczone.BuiltTemplates.remove_built_template_memories(built_template_id) do
          {:ok, built_template_id}
        end
      end)
    end

    field :remove_built_template_hard_drives, non_null(:id) do
      arg :built_template_id, non_null(:id)

      resolve(fn %{built_template_id: built_template_id}, _info ->
        with {_, nil} <-
               Pczone.BuiltTemplates.remove_built_template_hard_drives(built_template_id) do
          {:ok, built_template_id}
        end
      end)
    end

    field :generate_builts,
          non_null(list_of(non_null(:built))) do
      arg :code, non_null(:string)

      resolve(fn %{code: code}, _info ->
        with {:ok, {_, result}} <-
               Pczone.BuiltTemplates.generate_builts(code, returning: true) do
          {:ok, result}
        end
      end)
    end

    field :upsert_built_template_stores, non_null(list_of(non_null(:built_template_store))) do
      arg :data, non_null(list_of(non_null(:built_template_store_input)))

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <-
               Pczone.BuiltTemplateStores.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end

    field :add_built_template_taxon, non_null(:built_template_taxon) do
      arg :data, non_null(:add_built_template_taxon_input)

      resolve(fn %{data: data}, _info ->
        BuiltTemplates.add_taxonomy(data)
      end)
    end

    field :remove_built_template_taxon, non_null(:built_template_taxon) do
      arg :data, non_null(:remove_built_template_taxon_input)

      resolve(fn %{data: data}, _info ->
        BuiltTemplates.remove_taxonomy(data)
      end)
    end

    field :add_built_template_taxonomies,
          non_null(list_of(non_null(:built_template_taxon))) do
      arg :data, non_null(:add_built_template_taxonomies_input)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- BuiltTemplates.add_taxonomies(data) do
          {:ok, result}
        end
      end)
    end

    field :remove_built_template_taxonomies, non_null(:integer) do
      arg :data, non_null(:remove_built_template_taxon_input)

      resolve(fn %{data: data}, _info ->
        with {:ok, {removed, _}} <- BuiltTemplates.remove_taxonomies(data) do
          {:ok, removed}
        end
      end)
    end
  end
end
