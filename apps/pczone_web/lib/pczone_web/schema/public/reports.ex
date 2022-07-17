defmodule PczoneWeb.Schema.Reports do
  use Absinthe.Schema.Notation

  object :report do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :type, non_null(:string)
    field :path, non_null(:string)
    field :category, non_null(:string)
    field :size, non_null(:integer)
    field :inserted_at, non_null(:datetime)
    field :update_at, non_null(:datetime)
  end

  input_object :report_filter_input do
    field :name, :string_filter_input
    field :type, :string_filter_input
    field :category, :string_filter_input
    field :inserted_at, :datetime_filter_input
  end

  object :report_list_result do
    field :entities, non_null(list_of(non_null(:report)))
    field :paging, non_null(:paging)
  end

  object :report_queries do
    field :reports, non_null(:report_list_result) do
      arg :filter, :report_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Reports.list()

        {:ok, list}
      end)
    end
  end
end
