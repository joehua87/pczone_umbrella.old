defmodule PcZoneWeb.Schema.HardDrives do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers

  object :hard_drive do
    field :id, non_null(:id)
    field :slug, non_null(:string)
    field :name, non_null(:string)

    field :brand,
          :brand,
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
end
