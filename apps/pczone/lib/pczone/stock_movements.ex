defmodule Pczone.StockMovements do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, StockMovement, StockMovementItem, ProductStock}

  def get(id) do
    Repo.get(StockMovement, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.StockMovement
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def create() do
    StockMovement.new_changeset(%{}) |> Repo.insert()
  end

  def add_item(params) do
    params |> StockMovementItem.new_changeset() |> Repo.insert()
  end

  def add_items(list) do
    list =
      list
      |> Enum.map(
        &(&1
          |> StockMovementItem.new_changeset()
          |> Pczone.Helpers.get_changeset_changes())
      )

    Repo.insert_all_2(StockMovementItem, list,
      returning: true,
      on_conflict: {:replace, [:quantity]},
      conflict_target: [:stock_movement_id, :product_id, :code]
    )
  end

  def remove_item(id) do
    Repo.get(StockMovement, id) |> Ecto.Changeset.change() |> Repo.delete()
  end

  def update_item() do
  end

  def submit(%StockMovement{id: id, state: :created} = entity) do
    product_stock_changes =
      Repo.all(from(i in StockMovementItem, where: i.stock_movement_id == ^id))
      |> calculate_product_stock_changes()

    keys = Enum.map(product_stock_changes, &"#{&1.product_id}:#{&1.code}:#{&1.location}")

    product_stocks_map =
      Repo.all(
        from(ps in ProductStock,
          where:
            fragment(
              "CONCAT(?, ':', ?, ':', ?) = ANY(?)",
              ps.product_id,
              ps.code,
              ps.location,
              ^keys
            ),
          select:
            {fragment("CONCAT(?, ':', ?, ':', ?)", ps.product_id, ps.code, ps.location),
             ps.quantity}
        )
      )
      |> Enum.into(%{})

    next_product_stocks =
      product_stock_changes
      |> Enum.map(fn %{
                       code: code,
                       product_id: product_id,
                       quantity: quantity,
                       location: location
                     } ->
        quantity = Map.get(product_stocks_map, "#{product_id}:#{code}:#{location}", 0) + quantity

        %{
          code: code,
          product_id: product_id,
          quantity: quantity,
          location: location
        }
      end)

    submitted_at = Pczone.Helpers.utc_datetime()
    changeset = entity |> Ecto.Changeset.change(%{submitted_at: submitted_at, state: :submitted})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:stock_movement, changeset)
    |> Ecto.Multi.run(:items, fn _, _ ->
      Repo.insert_all_2(ProductStock, next_product_stocks,
        on_conflict: {:replace, [:quantity]},
        conflict_target: [:product_id, :code]
      )
    end)
    |> Repo.transaction()
  end

  def submit(id) do
    Repo.get(StockMovement, id) |> submit()
  end

  def cancel() do
  end

  def calculate_product_stock_changes(items) do
    items
    |> Enum.flat_map(fn
      %StockMovementItem{
        code: code,
        product_id: product_id,
        quantity: quantity,
        source_location: "external",
        destination_location: destination_location
      } ->
        [
          %{
            code: code,
            product_id: product_id,
            quantity: quantity,
            location: destination_location
          }
        ]

      %StockMovementItem{
        code: code,
        product_id: product_id,
        quantity: quantity,
        source_location: source_location,
        destination_location: "external"
      } ->
        [
          %{
            code: code,
            product_id: product_id,
            quantity: -quantity,
            location: source_location
          }
        ]

      %StockMovementItem{
        code: code,
        product_id: product_id,
        quantity: quantity,
        source_location: source_location,
        destination_location: destination_location
      } ->
        [
          %{
            code: code,
            product_id: product_id,
            quantity: -quantity,
            location: source_location
          },
          %{
            code: code,
            product_id: product_id,
            quantity: quantity,
            location: destination_location
          }
        ]
    end)
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :state -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
