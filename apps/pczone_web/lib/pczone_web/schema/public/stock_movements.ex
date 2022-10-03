defmodule PczoneWeb.Schema.StockMovements do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias PczoneWeb.Dataloader

  enum :stock_movement_state do
    value :created
    value :submitted
    value :canceled
  end

  object :stock_movement do
    field :id, non_null(:id)
    field :submitted_at, :datetime
    field :state, non_null(:stock_movement_state)

    field :items, non_null(list_of(non_null(:stock_movement_item))),
      resolve: Helpers.dataloader(Dataloader)
  end

  object :stock_movement_item do
    field :id, non_null(:id)
    field :code, non_null(:string)
    field :product_id, non_null(:id)
    field :product, non_null(:product), resolve: Helpers.dataloader(Dataloader)
    field :stock_movement_id, non_null(:id)
    field :stock_movement, non_null(:stock_movement), resolve: Helpers.dataloader(Dataloader)
    field :source_location, non_null(:string)
    field :destination_location, non_null(:string)
    field :quantity, non_null(:integer)
  end

  input_object :stock_movement_filter_input do
    field :state, :string_filter_input
  end

  object :stock_movement_list_result do
    field :entities, non_null(list_of(non_null(:stock_movement)))
    field :paging, non_null(:paging)
  end

  object :stock_movement_queries do
    field :stock_movement, non_null(:stock_movement) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Pczone.StockMovements.get(id)}
      end)
    end

    field :stock_movements, non_null(:stock_movement_list_result) do
      arg :filter, :stock_movement_filter_input
      arg :order_by, list_of(non_null(:order_by_input))
      arg :paging, :paging_input

      resolve(fn args, _info ->
        {:ok, Pczone.StockMovements.list(args)}
      end)
    end
  end

  input_object :add_stock_movement_item_input do
    field :code, non_null(:string)
    field :product_id, non_null(:id)
    field :stock_movement_id, non_null(:id)
    field :source_location, non_null(:string)
    field :destination_location, non_null(:string)
    field :quantity, non_null(:integer)
  end

  object :stock_movement_mutations do
    field :create_stock_movement, non_null(:stock_movement) do
      resolve(fn _, _info ->
        Pczone.StockMovements.create()
      end)
    end

    field :add_stock_movement_item, non_null(:stock_movement_item) do
      arg :data, non_null(:add_stock_movement_item_input)

      resolve(fn %{data: data}, _info ->
        Pczone.StockMovements.add_item(data)
      end)
    end

    field :add_stock_movement_items, non_null(list_of(non_null(:stock_movement_item))) do
      arg :data, non_null(list_of(non_null(:add_stock_movement_item_input)))

      resolve(fn %{data: data}, _info ->
        with {:ok, {_, list}} <- Pczone.StockMovements.add_items(data) do
          {:ok, list}
        end
      end)
    end

    field :remove_stock_movement_item, non_null(:stock_movement_item) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        Pczone.StockMovements.remove_item(id)
      end)
    end

    field :submit_stock_movement, non_null(:stock_movement) do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        Pczone.StockMovements.submit(id)
      end)
    end
  end
end
