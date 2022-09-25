defmodule PczoneWeb.Schema.Posts do
  use Absinthe.Schema.Notation

  object :post do
    field :id, non_null(:id)
    field :slug, :string
    field :title, non_null(:string)
    field :type, :string
    field :description, :string
    field :md, :string
    field :state, :string
    field :seo, :seo
    field :media, non_null(list_of(non_null(:embedded_medium)))
  end

  input_object :post_filter_input do
    field :slug, :string_filter_input
    field :title, :string_filter_input
  end

  object :post_list_result do
    field :entities, non_null(list_of(non_null(:post)))
    field :paging, non_null(:paging)
  end

  object :post_queries do
    field :posts, non_null(:post_list_result) do
      arg :filter, :post_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, info ->
        list =
          args
          |> Map.merge(%{
            selection: PczoneWeb.AbsintheHelper.project(info) |> Keyword.get(:entities)
          })
          |> Pczone.Posts.list()

        {:ok, list}
      end)
    end

    field :post, :post do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Pczone.Posts.get(id)}
      end)
    end

    field :post_by, :post do
      arg :filter, :post_filter_input

      resolve(fn args, _info ->
        {:ok, Pczone.Posts.get(args)}
      end)
    end
  end

  input_object :create_post_input do
    field :slug, :string
    field :title, non_null(:string)
    field :description, :string
    field :md, :string
    field :media, list_of(non_null(:embedded_medium_input))
    field :seo, :embedded_medium_input
    field :state, :string
  end

  input_object :update_post_input do
    field :slug, :string
    field :title, non_null(:string)
    field :description, :string
    field :md, :string
    field :media, list_of(non_null(:embedded_medium_input))
    field :seo, :embedded_medium_input
    field :state, :string
  end

  object :post_mutations do
    field :create_post, non_null(:post) do
      arg :data, non_null(:create_post_input)

      resolve(fn %{data: data}, _info ->
        Pczone.Posts.create(data)
      end)
    end

    field :update_post, non_null(:post) do
      arg :id, non_null(:id)
      arg :data, non_null(:update_post_input)

      resolve(fn %{id: id, data: data}, _info ->
        Pczone.Posts.update(id, data)
      end)
    end
  end
end
