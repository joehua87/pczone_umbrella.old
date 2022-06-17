defmodule PcZone.SimpleBuilts do
  import Ecto.Query, only: [from: 2]
  alias PcZone.Repo

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
        fn %{"code" => code, "name" => name, "barebone_product" => barebone_product_sku} ->
          %{
            id: barebone_id,
            product_id: barebone_product_id
          } = Map.get(barebone_products_map, barebone_product_sku)

          %{
            code: code,
            name: name,
            barebone_id: barebone_id,
            barebone_product_id: barebone_product_id
          }
        end
      )

    Ecto.Multi.new()
    |> Ecto.Multi.run(:simple_builts_map, fn _, _ ->
      {_, result} = Repo.insert_all(PcZone.SimpleBuilt, simple_builts, returning: true)

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
            fn %{"processor_product" => processor_product_sku} = params ->
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
                gpu_id: gpu_id,
                gpu_product_id: gpu_product_id,
                gpu_quantity: gpu_quantity
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
          Enum.map(memories, fn %{"memory_product" => memory_product_sku} = params ->
            %{
              id: memory_id,
              product_id: memory_product_id
            } = Map.get(memory_products_map, memory_product_sku)

            %{
              simple_built_id: Map.get(simple_builts_map, code),
              memory_id: memory_id,
              memory_product_id: memory_product_id,
              quantity: Map.get(params, "quantity", 1)
            }
          end)
        end)

      with {inserted, _} <- Repo.insert_all(PcZone.SimpleBuiltMemory, entities) do
        {:ok, inserted}
      end
    end)
    |> Ecto.Multi.run(:simple_built_hard_drives, fn _, %{simple_builts_map: simple_builts_map} ->
      entities =
        Enum.flat_map(list, fn %{"code" => code, "hard_drives" => hard_drives} ->
          Enum.map(hard_drives, fn %{"hard_drive_product" => hard_drive_product_sku} = params ->
            %{
              id: hard_drive_id,
              product_id: hard_drive_product_id
            } = Map.get(hard_drive_products_map, hard_drive_product_sku)

            %{
              simple_built_id: Map.get(simple_builts_map, code),
              hard_drive_id: hard_drive_id,
              hard_drive_product_id: hard_drive_product_id,
              quantity: Map.get(params, "quantity", 1)
            }
          end)
        end)

      with {inserted, _} <- Repo.insert_all(PcZone.SimpleBuiltHardDrive, entities) do
        {:ok, inserted}
      end
    end)
    |> Repo.transaction()
  end

  def generate_variants(%PcZone.SimpleBuilt{
        barebone_id: barebone_id,
        barebone_product: barebone_product,
        processors: processors,
        memories: memories,
        hard_drives: hard_drives
      }) do
    memories_and_hard_drives =
      memories
      |> Enum.flat_map(fn %PcZone.SimpleBuiltMemory{
                            memory_id: memory_id,
                            memory_product: memory_product,
                            quantity: memory_quantity
                          } ->
        hard_drives
        |> Enum.map(fn %PcZone.SimpleBuiltHardDrive{
                         hard_drive_id: hard_drive_id,
                         hard_drive_product: hard_drive_product,
                         quantity: hard_drive_quantity
                       } ->
          memory_amount = memory_quantity * memory_product.sale_price
          hard_drive_amount = hard_drive_quantity * hard_drive_product.sale_price

          %{
            memory_id: memory_id,
            memory_product_id: memory_product.id,
            memory_price: memory_product.sale_price,
            memory_quantity: memory_quantity,
            memory_amount: memory_amount,
            hard_drive_id: hard_drive_id,
            hard_drive_product_id: hard_drive_product.id,
            hard_drive_price: hard_drive_product.sale_price,
            hard_drive_quantity: hard_drive_quantity,
            hard_drive_amount: hard_drive_amount
          }
        end)
      end)

    processors
    |> Enum.flat_map(fn %PcZone.SimpleBuiltProcessor{
                          processor_id: processor_id,
                          processor_product: processor_product,
                          processor_quantity: processor_quantity,
                          gpu_product: gpu_product,
                          gpu_quantity: gpu_quantity
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

      Enum.map(memories_and_hard_drives, fn memory_and_hard_drive ->
        %{
          barebone_id: barebone_id,
          barebone_product_id: barebone_product.id,
          barebone_price: barebone_product.sale_price,
          processor_id: processor_id,
          processor_product_id: processor_product.id,
          processor_price: processor_product.sale_price,
          processor_quantity: processor_quantity,
          processor_amount: processor_amount
        }
        |> Map.merge(gpu)
        |> Map.merge(memory_and_hard_drive)
      end)
    end)
  end

  def generate_products(code) when is_bitstring(code) do
  end
end
