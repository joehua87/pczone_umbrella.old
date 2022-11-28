defmodule PczoneWeb.Schema.Products do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias Pczone.Products

  enum :product_type do
    value :barebone
    value :motherboard
    value :processor
    value :memory
    value :gpu
    value :hard_drive
    value :psu
    value :chassis
  end

  object :component_product do
    field :type, :product_type
    field :barebone_id, :id
    field :motherboard_id, :id
    field :processor_id, :id
    field :memory_id, :id
    field :gpu_id, :id
    field :hard_drive_id, :id
    field :psu_id, :id
    field :chassis_id, :id
    field :product_id, :id
    field :barebone, :barebone, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :motherboard, :motherboard, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :processor, :processor, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :memory, :memory, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :gpu, :gpu, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :hard_drive, :hard_drive, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :psu, :psu, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :chassis, :chassis, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
    field :product, non_null(:product), resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  object :product do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :condition, non_null(:string)
    field :component_type, :product_type
    field :list_price, :integer
    field :sale_price, non_null(:integer)
    field :percentage_off, non_null(:decimal)
    field :stock, non_null(:integer)
    field :media, non_null(list_of(non_null(:embedded_medium)))

    field :component_product,
          :component_product,
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :taxons,
          non_null(list_of(non_null(:taxon))),
          resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :post, :post, resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  object :product_taxon do
    field :product_id, non_null(:id)
    field :taxonomy_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :product_filter_input do
    field :id, :id_filter_input
    field :slug, :string_filter_input
    field :title, :string_filter_input
    field :condition, :string_filter_input
    field :component_type, :string_filter_input
    field :is_bundled, :boolean_filter_input
    field :taxons, list_of(non_null(:taxon_filter_input))
  end

  object :product_list_result do
    field :entities, non_null(list_of(non_null(:product)))
    field :paging, non_null(:paging)
  end

  object :product_queries do
    field :products, non_null(:product_list_result) do
      arg :filter, :product_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Products.list()

        {:ok, list}
      end)
    end

    field :product, :product do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Products.get(id)}
      end)
    end

    field :product_by, :product do
      arg :filter, :product_filter_input

      resolve(fn args, _info ->
        {:ok, Products.get(args)}
      end)
    end
  end

  input_object :create_product_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :condition, non_null(:string)
    field :list_price, :integer
    field :sale_price, non_null(:integer)
    field :stock, :integer
    field :type, non_null(:product_type)
    field :barebone_id, :id
    field :motherboard_id, :id
    field :processor_id, :id
    field :memory_id, :id
    field :gpu_id, :id
    field :hard_drive_id, :id
    field :psu_id, :id
    field :chassis_id, :id
    field :media, list_of(non_null(:embedded_medium_input))
  end

  input_object :update_product_input do
    field :slug, :string
    field :title, :string
    field :condition, :string
    field :list_price, :integer
    field :sale_price, :integer
    field :stock, :integer
    field :media, list_of(non_null(:embedded_medium_input))
  end

  input_object :add_product_taxon_input do
    field :product_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :remove_product_taxon_input do
    field :product_id, non_null(:id)
    field :taxon_id, non_null(:id)
  end

  input_object :add_product_taxonomies_input do
    field :product_id, non_null(:id)
    field :taxon_ids, non_null(list_of(non_null(:id)))
  end

  input_object :remove_product_taxonomies_input do
    field :product_id, non_null(:id)
    field :taxon_ids, non_null(list_of(non_null(:id)))
  end

  object :product_mutations do
    field :create_product, non_null(:product) do
      arg :data, non_null(:create_product_input)

      resolve(fn %{data: data}, _info ->
        Products.create(data)
      end)
    end

    field :update_product, non_null(:product) do
      arg :id, non_null(:id)
      arg :data, non_null(:update_product_input)

      resolve(fn %{id: id, data: data}, _info ->
        Products.update(id, data)
      end)
    end

    field :create_product_post, non_null(:post) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        Products.create_post(id)
      end)
    end

    field :add_product_taxon, non_null(:product_taxon) do
      arg :data, non_null(:add_product_taxon_input)

      resolve(fn %{data: data}, _info ->
        Products.add_taxonomy(data)
      end)
    end

    field :remove_product_taxon, non_null(:product_taxon) do
      arg :data, non_null(:remove_product_taxon_input)

      resolve(fn %{data: data}, _info ->
        Products.remove_taxonomy(data)
      end)
    end

    field :add_product_taxonomies, non_null(list_of(non_null(:product_taxon))) do
      arg :data, non_null(:add_product_taxonomies_input)

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, result}} <- Products.add_taxonomies(data) do
          {:ok, result}
        end
      end)
    end

    field :remove_product_taxonomies, non_null(:integer) do
      arg :data, non_null(:remove_product_taxon_input)

      resolve(fn %{data: data}, _info ->
        with {:ok, {removed, _}} <- Products.remove_taxonomies(data) do
          {:ok, removed}
        end
      end)
    end
  end
end
