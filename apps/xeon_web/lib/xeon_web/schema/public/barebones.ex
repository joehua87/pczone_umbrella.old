defmodule XeonWeb.Schema.Barebones do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias Xeon.Barebones

  object :barebone do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :motherboard_id, non_null(:id)
    field :chassis_id, non_null(:id)
    field :psu_id, :id
    field :brand_id, :id
    field :motherboard, non_null(:motherboard), resolve: Helpers.dataloader(XeonWeb.Dataloader)
    field :chassis, non_null(:chassis), resolve: Helpers.dataloader(XeonWeb.Dataloader)
    field :psu, :psu, resolve: Helpers.dataloader(XeonWeb.Dataloader)
    field :brand, :brand, resolve: Helpers.dataloader(XeonWeb.Dataloader)
    field :launch_date, :string
    field :raw_data, :json
    field :source_website, :string
    field :source_url, :string

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(XeonWeb.Dataloader)
  end

  input_object :barebone_filter_input do
    field :name, :string_filter_input
  end

  object :barebone_list_result do
    field :entities, non_null(list_of(non_null(:barebone)))
    field :paging, non_null(:paging)
  end

  object :barebone_queries do
    field :barebones, non_null(:barebone_list_result) do
      arg :filter, :barebone_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: XeonWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Barebones.list()

        {:ok, list}
      end
    end

    field :barebone, :barebone do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Barebones.get(id)}
      end)
    end

    field :barebone_by, :barebone do
      arg :filter, :barebone_filter_input

      resolve(fn args, _info ->
        {:ok, Barebones.get(args)}
      end)
    end
  end
end
