defmodule PcZone.Builts do
  import Ecto.Query, only: [from: 2]
  alias PcZone.{Repo, Motherboard, Memory, Processor, ChipsetProcessor}

  defmodule CreateBuiltParams do
    defstruct name: nil,
              motherboard_id: nil,
              chassis_id: nil,
              psu_id: nil,
              barebone_id: nil,
              extension_devices: nil,
              processors: nil,
              memories: nil,
              hard_drives: nil,
              gpus: nil
  end

  def processor_ids_query(motherboard_id) do
    processor_ids_query =
      from(mp in PcZone.MotherboardProcessor,
        where: mp.motherboard_id == ^motherboard_id,
        select: mp.processor_id
      )

    if Repo.aggregate(processor_ids_query, :count) > 0 do
      processor_ids_query
    else
      %{chipset_id: chipset_id} = Repo.get(Motherboard, motherboard_id)

      from(pc in ChipsetProcessor,
        where: pc.chipset_id == ^chipset_id,
        select: pc.processor_id
      )
    end
  end

  @doc """
  Get processors for a motherboard. If motherboard has specified processors, return them; otherwise return processors by motherboard chipset
  """
  def get_processors(motherboard_id) do
    Repo.all(from(p in Processor, where: p.id in subquery(processor_ids_query(motherboard_id))))
  end

  def get_memories(motherboard_id) do
    %{memory_slots: memory_slots} = Repo.get(Motherboard, motherboard_id)
    memory_types = Enum.flat_map(memory_slots, & &1.supported_types)
    Repo.all(from(m in Memory, where: m.type in ^memory_types))
  end

  def create(
        %{
          name: name,
          barebone_id: barebone_id,
          barebone_product_id: barebone_product_id,
          processor: processor,
          memory: memory
        } = params
      ) do
    # gpus = Map.get(params, :gpus, [])
    slug =
      case params do
        %{slug: slug = [_ | _]} -> slug
        _ -> Slug.slugify(name)
      end

    hard_drives = Map.get(params, :hard_drives, [])

    case Ecto.Multi.new()
         |> get_products_map(params)
         |> Ecto.Multi.run(:built, fn _, %{products_map: products_map} ->
           %{barebone_price: barebone_price, total: total} =
             calculate_built_price(params, products_map)

           PcZone.Built.new_changeset(%{
             name: name,
             slug: slug,
             barebone_id: barebone_id,
             barebone_product_id: barebone_product_id,
             barebone_price: barebone_price,
             total: total
           })
           |> Repo.insert()
         end)
         |> create_built_processor(processor)
         |> create_built_memory(memory)
         |> create_built_hard_drives(hard_drives)
         |> Repo.transaction() do
      {:ok, %{built: built}} -> {:ok, built}
      {:error, _, changeset, _} -> {:error, changeset}
      reason -> reason
    end
  end

  def create(
        %{
          motherboard_id: motherboard_id,
          motherboard_product_id: motherboard_product_id,
          chassis_id: chassis_id,
          chassis_product_id: chassis_product_id,
          psus: _psus,
          processor: processor,
          memory: memory,
          hard_drives: hard_drives,
          gpus: _gpus
        } = params
      ) do
    built_changeset =
      PcZone.Built.new_changeset(%{
        motherboard_id: motherboard_id,
        motherboard_product_id: motherboard_product_id,
        chassis_id: chassis_id,
        chassis_product_id: chassis_product_id
      })

    case Ecto.Multi.new()
         |> get_products_map(params)
         |> Ecto.Multi.insert(:built, built_changeset)
         |> create_built_processor(processor)
         |> create_built_memory(memory)
         |> create_built_hard_drives(hard_drives)
         |> Repo.transaction() do
      {:ok, %{built: built}} -> {:ok, built}
      {:error, _, changeset, _} -> {:error, changeset}
      reason -> reason
    end
  end

  defp get_products_map(
         multi,
         %{
           barebone_product_id: barebone_product_id,
           processor: %{product_id: processor_product_id},
           memory: %{product_id: memory_product_id}
         } = params
       ) do
    hard_drives = Map.get(params, :hard_drives, [])
    psus = Map.get(params, :psus, [])
    gpus = Map.get(params, :gpus, [])

    product_ids =
      [barebone_product_id, processor_product_id, memory_product_id] ++
        Enum.map(hard_drives, & &1.product_id) ++
        Enum.map(psus, & &1.product_id) ++
        Enum.map(gpus, & &1.product_id)

    multi
    |> Ecto.Multi.run(:products_map, fn _, _ ->
      case Repo.all(from p in PcZone.Product, where: p.id in ^product_ids, select: {p.id, p})
           |> Enum.into(%{}) do
        products_map = %{} -> {:ok, products_map}
        reason -> reason
      end
    end)
  end

  defp create_built_processor(multi, processor = %{product_id: product_id, quantity: quantity}) do
    multi
    |> Ecto.Multi.run(
      :built_processor,
      fn _, %{built: %{id: built_id}, products_map: products_map} ->
        %{sale_price: price} = products_map[product_id]

        processor
        |> Map.merge(%{
          built_id: built_id,
          price: price,
          total: price * quantity
        })
        |> PcZone.BuiltProcessor.new_changeset()
        |> Repo.insert()
      end
    )
  end

  defp create_built_memory(multi, memory = %{product_id: product_id, quantity: quantity}) do
    multi
    |> Ecto.Multi.run(
      :built_memory,
      fn _, %{built: %{id: built_id}, products_map: products_map} ->
        %{sale_price: price} = products_map[product_id]

        memory
        |> Map.merge(%{
          built_id: built_id,
          price: price,
          total: price * quantity
        })
        |> PcZone.BuiltMemory.new_changeset()
        |> Repo.insert()
      end
    )
  end

  defp create_built_hard_drives(multi, hard_drives) do
    multi
    |> Ecto.Multi.run(
      :built_hard_drives,
      fn _, %{built: %{id: built_id}, products_map: products_map} ->
        hard_drives =
          Enum.map(hard_drives, fn %{product_id: product_id, quantity: quantity} = hard_drive ->
            %{sale_price: price} = products_map[product_id]

            hard_drive
            |> Map.merge(%{
              built_id: built_id,
              price: price,
              total: price * quantity
            })
          end)

        case Repo.insert_all(PcZone.BuiltHardDrive, hard_drives, returning: true) do
          {inserted, list} when is_integer(inserted) -> {:ok, list}
          reason -> reason
        end
      end
    )
  end

  defp calculate_built_price(
         %{
           barebone_product_id: barebone_product_id,
           processor: %{product_id: processor_product_id, quantity: processor_quantity},
           memory: %{product_id: memory_product_id, quantity: memory_quantity}
         } = params,
         products_map
       ) do
    hard_drives = Map.get(params, :hard_drives, [])
    psus = Map.get(params, :psus, [])
    gpus = Map.get(params, :gpus, [])
    %{sale_price: barebone_price} = products_map[barebone_product_id]
    %{sale_price: processor_price} = products_map[processor_product_id]
    %{sale_price: memory_price} = products_map[memory_product_id]
    hard_drives_price = calculate_list_price(hard_drives, products_map)
    psus_price = calculate_list_price(psus, products_map)
    gpus_price = calculate_list_price(gpus, products_map)

    total =
      [
        barebone_price,
        processor_price * processor_quantity,
        memory_price * memory_quantity,
        hard_drives_price,
        psus_price,
        gpus_price
      ]
      |> Enum.sum()

    %{
      barebone_price: barebone_price,
      total: total
    }
  end

  defp calculate_list_price(list, products_map) do
    list
    |> Enum.map(fn %{product_id: product_id, quantity: quantity} ->
      %{sale_price: price} = products_map[product_id]
      price * quantity
    end)
    |> Enum.sum()
  end

  def validate_chassis(
        %PcZone.Motherboard{chassis_form_factors: chassis_form_factors},
        %PcZone.Chassis{form_factor: form_factor}
      ) do
    if Enum.member?(chassis_form_factors, form_factor),
      do: :ok,
      else: {:error, "Invalid chassis form factor"}
  end

  def validate_psus(%PcZone.Chassis{}, [_ | _]) do
    {:error, "Only support built with 1 psu now"}
  end

  def validate_psus(%PcZone.Chassis{psu_form_factors: psu_form_factors}, [%{psu_id: psu_id}]) do
    case Repo.get(PcZone.Psu, psu_id) do
      %PcZone.Psu{form_factor: form_factor} ->
        if Enum.member?(psu_form_factors, form_factor),
          do: :ok,
          else: {:error, "Invalid psu form factor"}

      nil ->
        {:error, {"Invalid psu id", psu_id: psu_id}}
    end
  end

  def validate_extension_devices(%PcZone.ExtensionDevice{}, _extension_devices) do
  end

  def validate_processors(%PcZone.Motherboard{processor_slots: processor_slots}, processors)
      when length(processor_slots) != 1 or length(processors) != 1 do
    {:error, "Only support motherboard which has 1 processor type"}
  end

  def validate_processors(
        %PcZone.Motherboard{
          id: motherboard_id,
          processor_slots: [%PcZone.ProcessorSlot{} = slot]
        },
        [%{processor_id: processor_id, quantity: quantity}]
      ) do
    if quantity > slot.quantity do
      {:error,
       {"More processors {processors_count} than processor slots {slots_count}",
        processor_count: quantity, slot_count: slot.quantity}}
    else
      case Repo.one(from(id in processor_ids_query(motherboard_id), where: id == ^processor_id)) do
        nil -> {:error, "Processor is not support by motherboard"}
        _ -> :ok
      end
    end
  end

  def validate_memories(%PcZone.Motherboard{memory_slots: memory_slots}, memories) do
    memory_slots_map = get_slots_map(memory_slots)
    memories_map = Repo.all(from(m in PcZone.Memory, select: {m.id, m})) |> Enum.into(%{})

    errors =
      memories
      |> Enum.map(fn %{
                       memory_id: memory_id,
                       processor_index: processor_index,
                       slot_type: slot_type,
                       quantity: quantity
                     } ->
        memory = memories_map[memory_id]
        slot = memory_slots_map["#{slot_type}:#{processor_index}"]
        is_supported = Enum.member?(slot.supported_types, memory.type)

        cond do
          quantity > slot.quantity ->
            {:error,
             {"Slot {slot_type} only support {slot_quantity} items",
              [slot_type: slot_type, slot_quantity: slot.quantity]}}

          is_supported && memory.capacity > slot.max_capacity ->
            {:error,
             {
               "Motherboard does not support memory capacity more than {capacity}",
               capacity: slot.max_capacity
             }}

          is_supported ->
            :ok

          true ->
            {:error,
             {
               "Motherboard does not support memory type {memory_type}",
               memory_type: memory.type
             }}
        end
      end)
      |> Enum.filter(&(&1 != :ok))

    if length(errors) == 0 do
      :ok
    else
      # TODO: Combine errors
      errors[0]
    end
  end

  def validate_hard_drives(
        %PcZone.Motherboard{m2_slots: m2_slots, sata_slots: sata_slots},
        hard_drives
      ) do
    m2_slots_map = get_slots_map(m2_slots)
    sata_slots_map = get_slots_map(sata_slots)
    slots_map = Map.merge(m2_slots_map, sata_slots_map)
    hard_drives_map = Repo.all(from(m in PcZone.HardDrive, select: {m.id, m})) |> Enum.into(%{})

    errors =
      hard_drives
      |> Enum.map(fn %{
                       hard_drive_id: hard_drive_id,
                       processor_index: processor_index,
                       type: slot_type,
                       quantity: quantity
                     } ->
        hard_drive = hard_drives_map[hard_drive_id]
        slot = slots_map["#{slot_type}:#{processor_index}"]
        is_supported = Enum.member?(slot.supported_types, hard_drive.type)

        cond do
          quantity > slot.quantity ->
            {:error,
             {"Slot {slot_type} only support {slot_quantity} items",
              [slot_type: slot_type, slot_quantity: slot.quantity]}}

          is_supported ->
            :ok

          true ->
            {:error,
             {
               "Motherboard does not support type {slot_type}",
               slot_type: hard_drive.slot_type
             }}
        end
      end)
      |> Enum.filter(&(&1 != :ok))

    if length(errors) == 0 do
      :ok
    else
      # TODO: Combine errors
      errors[0]
    end
  end

  def validate_gpus(%PcZone.Motherboard{pci_slots: pci_slots}, gpus) do
    pci_slots_map = get_slots_map(pci_slots)
    gpus_map = Repo.all(from(m in PcZone.Gpu, select: {m.id, m})) |> Enum.into(%{})

    errors =
      gpus
      |> Enum.map(fn %{
                       gpu_id: gpu_id,
                       processor_index: processor_index,
                       slot_type: slot_type,
                       quantity: quantity
                     } ->
        gpu = gpus_map[gpu_id]
        slot = pci_slots_map["#{slot_type}:#{processor_index}"]
        is_supported = Enum.member?(slot.supported_types, gpu.slot_type)

        cond do
          quantity > slot.quantity ->
            {:error,
             {"Slot {slot_type} only support {slot_quantity} items",
              [slot_type: slot_type, slot_quantity: slot.quantity]}}

          is_supported ->
            :ok

          true ->
            {
              :error,
              {"Motherboard does not support pci type {slot_type}", slot_type: gpu.slot_type}
            }
        end
      end)
      |> Enum.filter(&(&1 != :ok))

    if length(errors) == 0 do
      :ok
    else
      # TODO: Combine errors
      errors[0]
    end
  end

  @doc """
  Extract a list of products for a built
  """
  def extract_products(built_id) do
  end

  @doc """
  Check if products is in stocks for a built
  """
  def validate_products(built_id) do
  end

  defp get_slots_map(slots) do
    Enum.map(
      slots,
      fn %{type: type, processor_index: processor_index} = slot ->
        {"#{type}:#{processor_index}", slot}
      end
    )
    |> Enum.into(%{})
  end
end
