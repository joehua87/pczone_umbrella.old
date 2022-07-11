defmodule PcZone.SimpleBuilts do
  import Ecto.Query, only: [where: 2, from: 2]
  import Dew.FilterParser
  alias PcZone.Repo

  def get(id) do
    Repo.get(PcZone.SimpleBuilt, id)
  end

  def get_by_code(code) do
    Repo.one(from PcZone.SimpleBuilt, where: [code: ^code], limit: 1)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    PcZone.SimpleBuilt
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(list) do
    barebone_product_skus =
      Enum.map(list, fn %{"barebone_product" => barebone_product} ->
        barebone_product
      end)

    processor_product_skus =
      Enum.flat_map(list, fn %{"processors" => processors} ->
        Enum.map(processors, & &1["processor_product"])
      end)

    gpu_product_skus =
      Enum.flat_map(list, fn %{"processors" => processors} ->
        Enum.map(processors, & &1["gpu_product"]) |> Enum.filter(&(&1 != nil))
      end)

    memory_product_skus =
      Enum.flat_map(list, fn %{"memories" => memories} ->
        Enum.map(memories, & &1["memory_product"])
      end)

    hard_drive_product_skus =
      Enum.flat_map(list, fn %{"hard_drives" => hard_drives} ->
        Enum.map(hard_drives, & &1["hard_drive_product"])
      end)

    barebone_products_map =
      Repo.all(
        from p in PcZone.Product,
          where: p.sku in ^barebone_product_skus,
          select: {p.sku, %{id: p.barebone_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    processor_products_map =
      Repo.all(
        from p in PcZone.Product,
          where: p.sku in ^processor_product_skus,
          select: {p.sku, %{id: p.processor_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    gpu_products_map =
      Repo.all(
        from p in PcZone.Product,
          where: p.sku in ^gpu_product_skus,
          select: {p.sku, %{id: p.gpu_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    memory_products_map =
      Repo.all(
        from p in PcZone.Product,
          where: p.sku in ^memory_product_skus,
          select: {p.sku, %{id: p.memory_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    hard_drive_products_map =
      Repo.all(
        from p in PcZone.Product,
          where: p.sku in ^hard_drive_product_skus,
          select: {p.sku, %{id: p.hard_drive_id, product_id: p.id}}
      )
      |> Enum.into(%{})

    simple_builts =
      Enum.map(
        list,
        fn %{
             "code" => code,
             "name" => name,
             "body_template" => body_template,
             "barebone_product" => barebone_product_sku,
             "option_types" => option_types,
             "option_value_seperator" => option_value_seperator
           } ->
          %{
            id: barebone_id,
            product_id: barebone_product_id
          } = Map.get(barebone_products_map, barebone_product_sku)

          %{
            code: code,
            name: name,
            body_template: body_template,
            barebone_id: barebone_id,
            barebone_product_id: barebone_product_id,
            option_types: option_types,
            option_value_seperator: option_value_seperator
          }
        end
      )

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:simple_builts_map, fn _, _ ->
        {_, result} =
          Repo.insert_all(PcZone.SimpleBuilt, simple_builts,
            returning: true,
            on_conflict:
              {:replace,
               [
                 :name,
                 :body_template,
                 :barebone_id,
                 :barebone_product_id,
                 :option_types,
                 :option_value_seperator
               ]},
            conflict_target: [:code]
          )

        {:ok,
         Enum.map(result, fn %{id: id, code: code} ->
           {code, id}
         end)
         |> Enum.into(%{})}
      end)
      |> Ecto.Multi.run(:simple_built_processors, fn _, %{simple_builts_map: simple_builts_map} ->
        entities =
          Enum.flat_map(list, fn %{"code" => code, "processors" => processors} ->
            Enum.map(
              processors,
              fn %{
                   "processor_product" => processor_product_sku,
                   "processor_label" => processor_label
                 } = params ->
                %{
                  id: processor_id,
                  product_id: processor_product_id
                } = Map.get(processor_products_map, processor_product_sku)

                %{
                  gpu_id: gpu_id,
                  gpu_product_id: gpu_product_id,
                  gpu_quantity: gpu_quantity
                } =
                  with "" <> gpu_product_sku <- Map.get(params, "gpu_product_sku") do
                    %{
                      id: gpu_id,
                      product_id: gpu_product_id
                    } = Map.get(gpu_products_map, gpu_product_sku)

                    %{
                      gpu_id: gpu_id,
                      gpu_product_id: gpu_product_id,
                      gpu_quantity: Map.get(params, "gpu_quantity", 1)
                    }
                  else
                    _ ->
                      %{
                        gpu_id: nil,
                        gpu_product_id: nil,
                        gpu_quantity: 0
                      }
                  end

                %{
                  simple_built_id: Map.get(simple_builts_map, code),
                  processor_id: processor_id,
                  processor_product_id: processor_product_id,
                  processor_quantity: Map.get(params, "processor_quantity", 1),
                  processor_label: processor_label,
                  gpu_id: gpu_id,
                  gpu_product_id: gpu_product_id,
                  gpu_quantity: gpu_quantity,
                  gpu_label: Map.get(params, "gpu_label")
                }
              end
            )
          end)

        with {inserted, _} <- Repo.insert_all(PcZone.SimpleBuiltProcessor, entities) do
          {:ok, inserted}
        end
      end)
      |> Ecto.Multi.run(:simple_built_memories, fn _, %{simple_builts_map: simple_builts_map} ->
        entities =
          Enum.flat_map(list, fn %{"code" => code, "memories" => memories} ->
            Enum.map(
              memories,
              fn %{"memory_product" => memory_product_sku, "label" => label} = params ->
                %{
                  id: memory_id,
                  product_id: memory_product_id
                } = Map.get(memory_products_map, memory_product_sku)

                %{
                  simple_built_id: Map.get(simple_builts_map, code),
                  memory_id: memory_id,
                  memory_product_id: memory_product_id,
                  quantity: Map.get(params, "quantity", 1),
                  label: label
                }
              end
            )
          end)

        with {inserted, _} <- Repo.insert_all(PcZone.SimpleBuiltMemory, entities) do
          {:ok, inserted}
        end
      end)
      |> Ecto.Multi.run(:simple_built_hard_drives, fn _,
                                                      %{simple_builts_map: simple_builts_map} ->
        entities =
          Enum.flat_map(list, fn %{"code" => code, "hard_drives" => hard_drives} ->
            Enum.map(
              hard_drives,
              fn %{"hard_drive_product" => hard_drive_product_sku, "label" => label} = params ->
                %{
                  id: hard_drive_id,
                  product_id: hard_drive_product_id
                } = Map.get(hard_drive_products_map, hard_drive_product_sku)

                %{
                  simple_built_id: Map.get(simple_builts_map, code),
                  hard_drive_id: hard_drive_id,
                  hard_drive_product_id: hard_drive_product_id,
                  quantity: Map.get(params, "quantity", 1),
                  label: label
                }
              end
            )
          end)

        with {inserted, _} <- Repo.insert_all(PcZone.SimpleBuiltHardDrive, entities) do
          {:ok, inserted}
        end
      end)

    with {:ok, _} <- Repo.transaction(multi) do
      codes = Enum.map(list, & &1["code"])

      {:ok,
       Repo.all(
         from b in PcZone.SimpleBuilt,
           where: b.code in ^codes,
           preload: [
             :barebone,
             :barebone_product,
             {:processors, [:processor, :processor_product, :gpu, :gpu_product]},
             {:memories, [:memory, :memory_product]},
             {:hard_drives, [:hard_drive, :hard_drive_product]}
           ]
       )}
    end
  end

  def generate_variants(%PcZone.SimpleBuilt{
        id: simple_built_id,
        barebone_id: barebone_id,
        barebone_product: barebone_product,
        processors: processors,
        memories: memories,
        hard_drives: hard_drives,
        option_value_seperator: seperator
      }) do
    memories_and_hard_drives =
      [%PcZone.SimpleBuiltMemory{quantity: 0, memory_product: nil} | memories]
      |> Enum.flat_map(fn %PcZone.SimpleBuiltMemory{
                            memory_id: memory_id,
                            memory_product: memory_product,
                            quantity: memory_quantity,
                            label: memory_label
                          } ->
        [%PcZone.SimpleBuiltHardDrive{quantity: 0, hard_drive_product: nil} | hard_drives]
        |> Enum.map(fn %PcZone.SimpleBuiltHardDrive{
                         hard_drive_id: hard_drive_id,
                         hard_drive_product: hard_drive_product,
                         quantity: hard_drive_quantity,
                         label: hard_drive_label
                       } ->
          memory_data =
            if(memory_product,
              do: %{
                memory_id: memory_id,
                memory_product_id: memory_product.id,
                memory_price: memory_product.sale_price,
                memory_quantity: memory_quantity,
                memory_amount: memory_quantity * memory_product.sale_price
              },
              else: %{
                memory_id: nil,
                memory_product_id: nil,
                memory_price: 0,
                memory_quantity: 0,
                memory_amount: 0
              }
            )

          hard_drive_data =
            if(hard_drive_product,
              do: %{
                hard_drive_id: hard_drive_id,
                hard_drive_product_id: hard_drive_product.id,
                hard_drive_price: hard_drive_product.sale_price,
                hard_drive_quantity: hard_drive_quantity,
                hard_drive_amount: hard_drive_quantity * hard_drive_product.sale_price
              },
              else: %{
                hard_drive_id: nil,
                hard_drive_product_id: nil,
                hard_drive_price: 0,
                hard_drive_quantity: 0,
                hard_drive_amount: 0
              }
            )

          %{
            option_value_2:
              Enum.join(
                [memory_label || "Không RAM", hard_drive_label || "Không ổ cứng"],
                seperator
              )
          }
          |> Map.merge(memory_data)
          |> Map.merge(hard_drive_data)
        end)
      end)

    processors
    |> Enum.flat_map(fn %PcZone.SimpleBuiltProcessor{
                          processor_id: processor_id,
                          processor_product: processor_product,
                          processor_quantity: processor_quantity,
                          processor_label: processor_label,
                          gpu_product: gpu_product,
                          gpu_quantity: gpu_quantity,
                          gpu_label: gpu_label
                        } ->
      processor_amount = processor_quantity * processor_product.sale_price

      gpu =
        case gpu_product do
          nil ->
            %{gpu_product_id: nil, gpu_price: 0, gpu_quantity: 0, gpu_amount: 0}

          %{id: gpu_product_id, sale_price: gpu_price} ->
            %{
              gpu_product_id: gpu_product_id,
              gpu_price: gpu_price,
              gpu_quantity: gpu_quantity,
              gpu_amount: gpu_price * gpu_price
            }
        end

      gpu_label = if gpu_product != nil, do: gpu_label, else: nil

      option_value_1 =
        [processor_label, gpu_label] |> Enum.filter(&(&1 != nil)) |> Enum.join(seperator)

      Enum.map(
        memories_and_hard_drives,
        fn memory_and_hard_drive = %{option_value_2: option_value_2} ->
          result =
            %{
              simple_built_id: simple_built_id,
              barebone_id: barebone_id,
              barebone_product_id: barebone_product.id,
              barebone_price: barebone_product.sale_price,
              processor_id: processor_id,
              processor_product_id: processor_product.id,
              processor_price: processor_product.sale_price,
              processor_quantity: processor_quantity,
              processor_amount: processor_amount,
              option_values: [option_value_1, option_value_2]
            }
            |> Map.merge(gpu)
            |> Map.merge(Map.delete(memory_and_hard_drive, :option_value_2))

          total =
            result
            |> Map.take([
              :barebone_price,
              :gpu_amount,
              :hard_drive_amount,
              :memory_amount,
              :processor_amount
            ])
            |> Map.values()
            |> Enum.sum()

          Map.put(result, :total, total)
        end
      )
    end)
  end

  def generate_variants(code) when is_bitstring(code) do
    Repo.one(
      from b in PcZone.SimpleBuilt,
        where: b.code == ^code,
        preload: [
          :barebone,
          :barebone_product,
          {:processors, [:processor_product, :gpu_product]},
          {:memories, :memory_product},
          {:hard_drives, :hard_drive_product}
        ],
        limit: 1
    )
    |> generate_variants()
  end

  def upsert_variants(list, opts \\ []) do
    Repo.insert_all(
      PcZone.SimpleBuiltVariant,
      list,
      [
        on_conflict:
          {:replace,
           [
             :barebone_id,
             :barebone_product_id,
             :barebone_price,
             :processor_id,
             :processor_product_id,
             :processor_price,
             :processor_quantity,
             :memory_id,
             :memory_product_id,
             :memory_price,
             :memory_quantity,
             :hard_drive_id,
             :hard_drive_product_id,
             :hard_drive_price,
             :hard_drive_quantity,
             :total,
             :gpu_id,
             :gpu_product_id,
             :gpu_price,
             :gpu_quantity
           ]},
        conflict_target: [:simple_built_id, :option_values]
      ] ++ opts
    )
  end

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
