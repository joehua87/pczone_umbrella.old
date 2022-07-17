defmodule PczoneWeb.Schema.Media do
  use Absinthe.Schema.Notation

  object :medium do
    field :id, non_null(:id)
    field :remote_url, :string
    field :name, non_null(:string)
    field :ext, non_null(:string)
    field :mime, non_null(:string)
    field :caption, :string
    field :width, non_null(:decimal)
    field :height, non_null(:decimal)
    field :size, non_null(:decimal)
    field :status, non_null(:string)
    field :blurhash, non_null(:string)
    field :derived_files, non_null(list_of(non_null(:string)))
  end

  input_object :medium_filter_input do
    field :name, :string_filter_input
  end

  object :medium_list_result do
    field :entities, non_null(list_of(non_null(:medium)))
    field :paging, non_null(:paging)
  end

  object :medium_queries do
    field :media, non_null(:medium_list_result) do
      arg :filter, :medium_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Media.list()

        {:ok, list}
      end)
    end
  end
end
