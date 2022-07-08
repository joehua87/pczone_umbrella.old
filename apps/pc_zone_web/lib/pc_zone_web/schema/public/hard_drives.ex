defmodule PcZoneWeb.Schema.HardDrives do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :hard_drive do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)
    field :capacity, non_null(:integer)
    field :type, non_null(:string)
    field :form_factor, :string
    field :sequential_read, :integer
    field :sequential_write, :integer
    field :random_read, :integer
    field :random_write, :integer
    field :tbw, :integer
    field :brand_id, non_null(:id)

    field :brand,
          non_null(:brand),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)

    field :products,
          non_null(list_of(non_null(:product))),
          resolve: Helpers.dataloader(PcZoneWeb.Dataloader)
  end

  input_object :hard_drive_filter_input do
    field :name, :string_filter_input
    field :type, :string_filter_input
    field :form_factor, :string_filter_input
  end

  object :hard_drive_list_result do
    field :entities, non_null(list_of(non_null(:hard_drive)))
    field :paging, non_null(:paging)
  end

  object :hard_drive_queries do
    field :hard_drives, non_null(:hard_drive_list_result) do
      arg :filter, :hard_drive_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PcZoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> PcZone.HardDrives.list()

        {:ok, list}
      end)
    end
  end

  object :hard_drive_mutations do
    field :upsert_hard_drives, non_null(list_of(non_null(:hard_drive))) do
      arg :data, non_null(:json)

      resolve(fn %{data: data}, _info ->
        with {_, result} <- PcZone.HardDrives.upsert(data, returning: true) do
          {:ok, result}
        end
      end)
    end
  end
end
