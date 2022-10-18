defmodule Pczone.Builts do
  import Ecto.Query, only: [from: 2, where: 2]
  import Dew.FilterParser
  alias Pczone.{Repo, Motherboard, Memory, Processor, ChipsetProcessor}

  def get(id) do
    Repo.get(Pczone.Built, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Pczone.Built
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def calculate_built_products(built_ids) when is_list(built_ids) do
    items_1 =
      Repo.all(
        from b in Pczone.Built,
          select: [:id, :barebone_product_id, :motherboard_product_id, :chassis_product_id],
          where: b.id in ^built_ids
      )
      |> Enum.flat_map(fn %{
                            id: built_id,
                            barebone_product_id: barebone_product_id,
                            motherboard_product_id: motherboard_product_id,
                            chassis_product_id: chassis_product_id
                          } ->
        [
          barebone_product_id &&
            %{built_id: built_id, product_id: barebone_product_id, quantity: 1},
          motherboard_product_id &&
            %{built_id: built_id, product_id: motherboard_product_id, quantity: 1},
          chassis_product_id &&
            %{built_id: built_id, product_id: chassis_product_id, quantity: 1}
        ]
        |> Enum.filter(&(&1 != nil))
      end)

    items_2 =
      [
        Pczone.BuiltCooler,
        Pczone.BuiltExtensionDevice,
        Pczone.BuiltGpu,
        Pczone.BuiltHardDrive,
        Pczone.BuiltMemory,
        Pczone.BuiltProcessor,
        Pczone.BuiltPsu
      ]
      |> Enum.map(fn schema ->
        Repo.all(
          from x in schema,
            where: x.built_id in ^built_ids,
            select: map(x, [:built_id, :product_id, :quantity])
        )
      end)
      |> List.flatten()

    Repo.insert_all_2(Pczone.BuiltProduct, items_1 ++ items_2,
      on_conflict: {:replace, [:quantity]},
      conflict_target: [:built_id, :product_id]
    )
  end

  def calculate_built_products(built_id) do
    calculate_built_products([built_id])
  end

  def processor_ids_query(motherboard_id) do
    processor_ids_query =
      from(mp in Pczone.MotherboardProcessor,
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
         |> Ecto.Multi.run(:built, fn _, %{} ->
           Pczone.Built.new_changeset(%{
             name: name,
             slug: slug,
             barebone_id: barebone_id,
             barebone_product_id: barebone_product_id
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

  def create(%{
        motherboard_id: motherboard_id,
        motherboard_product_id: motherboard_product_id,
        chassis_id: chassis_id,
        chassis_product_id: chassis_product_id,
        psus: _psus,
        processor: processor,
        memory: memory,
        hard_drives: hard_drives,
        gpus: _gpus
      }) do
    built_changeset =
      Pczone.Built.new_changeset(%{
        motherboard_id: motherboard_id,
        motherboard_product_id: motherboard_product_id,
        chassis_id: chassis_id,
        chassis_product_id: chassis_product_id
      })

    case Ecto.Multi.new()
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

  def delete(built_id) do
    Repo.get(Pczone.Built, built_id) |> Repo.delete()
  end

  defp create_built_processor(multi, processor) do
    multi
    |> Ecto.Multi.run(
      :built_processor,
      fn _, %{built: %{id: built_id}} ->
        processor
        |> Map.merge(%{built_id: built_id})
        |> Pczone.BuiltProcessor.new_changeset()
        |> Repo.insert()
      end
    )
  end

  defp create_built_memory(multi, memory) do
    multi
    |> Ecto.Multi.run(
      :built_memory,
      fn _, %{built: %{id: built_id}} ->
        memory
        |> Map.merge(%{built_id: built_id})
        |> Pczone.BuiltMemory.new_changeset()
        |> Repo.insert()
      end
    )
  end

  defp create_built_hard_drives(multi, hard_drives) do
    multi
    |> Ecto.Multi.run(
      :built_hard_drives,
      fn _, %{built: %{id: built_id}} ->
        hard_drives =
          Enum.map(hard_drives, fn hard_drive ->
            hard_drive
            |> Map.merge(%{built_id: built_id})
          end)

        case Repo.insert_all(Pczone.BuiltHardDrive, hard_drives, returning: true) do
          {inserted, list} when is_integer(inserted) -> {:ok, list}
          reason -> reason
        end
      end
    )
  end

  def calculate_built_price(%Pczone.Built{
        barebone_product: %Pczone.Product{
          id: barebone_product_id,
          title: barebone_title,
          component_type: barebone_component_type,
          sale_price: barebone_price
        },
        built_processors: processors,
        built_memories: memories,
        built_hard_drives: hard_drives,
        built_gpus: gpus,
        built_psus: psus
      }) do
    product_ids =
      Enum.map(processors, & &1.product_id) ++
        Enum.map(memories, & &1.product_id) ++
        Enum.map(hard_drives, & &1.product_id) ++
        Enum.map(psus, & &1.product_id) ++
        Enum.map(gpus, & &1.product_id)

    products_map =
      Repo.all(from p in Pczone.Product, where: p.id in ^product_ids, select: {p.id, p})
      |> Enum.into(%{})

    items =
      [
        %{
          product_id: barebone_product_id,
          title: barebone_title,
          component_type: barebone_component_type,
          price: barebone_price,
          quantity: 1,
          total: barebone_price
        },
        calculate_list_total(processors, products_map),
        calculate_list_total(memories, products_map),
        calculate_list_total(hard_drives, products_map),
        calculate_list_total(psus, products_map),
        calculate_list_total(gpus, products_map)
      ]
      |> List.flatten()

    %{
      items: items,
      total: items |> Enum.map(& &1.total) |> Enum.sum()
    }
  end

  def calculate_built_price(built_id) do
    from(b in Pczone.Built,
      preload: [
        :barebone_product,
        :built_processors,
        :built_memories,
        :built_hard_drives,
        :built_psus,
        :built_gpus
      ]
    )
    |> Pczone.Repo.get(built_id)
    |> calculate_built_price()
  end

  def calculate_builts_price([]), do: []

  def calculate_builts_price([%Pczone.Built{} | _] = builts) do
    builts
    |> Enum.map(fn %Pczone.Built{id: built_id} = built ->
      {built_id, calculate_built_price(built)}
    end)
    |> Enum.into(%{})
  end

  def calculate_builts_price([_ | _] = built_ids) do
    from(b in Pczone.Built,
      where: b.id in ^built_ids,
      preload: [
        :barebone_product,
        :built_processors,
        :built_memories,
        :built_hard_drives,
        :built_psus,
        :built_gpus
      ]
    )
    |> Pczone.Repo.all()
    |> calculate_builts_price()
  end

  defp calculate_list_total(list, products_map) do
    list
    |> Enum.map(fn %{product_id: product_id, quantity: quantity} ->
      %{title: title, sale_price: price, component_type: component_type} =
        products_map[product_id]

      %{
        product_id: product_id,
        title: title,
        component_type: component_type,
        price: price,
        quantity: quantity,
        total: price * quantity
      }
    end)
  end

  def validate_chassis(
        %Pczone.Motherboard{chassis_form_factors: chassis_form_factors},
        %Pczone.Chassis{form_factor: form_factor}
      ) do
    if Enum.member?(chassis_form_factors, form_factor),
      do: :ok,
      else: {:error, "Invalid chassis form factor"}
  end

  def validate_psus(%Pczone.Chassis{}, [_ | _]) do
    {:error, "Only support built with 1 psu now"}
  end

  def validate_psus(%Pczone.Chassis{psu_form_factors: psu_form_factors}, [%{psu_id: psu_id}]) do
    case Repo.get(Pczone.Psu, psu_id) do
      %Pczone.Psu{form_factor: form_factor} ->
        if Enum.member?(psu_form_factors, form_factor),
          do: :ok,
          else: {:error, "Invalid psu form factor"}

      nil ->
        {:error, {"Invalid psu id", psu_id: psu_id}}
    end
  end

  def validate_extension_devices(%Pczone.ExtensionDevice{}, _extension_devices) do
  end

  def validate_processors(%Pczone.Motherboard{processor_slots: processor_slots}, processors)
      when length(processor_slots) != 1 or length(processors) != 1 do
    {:error, "Only support motherboard which has 1 processor type"}
  end

  def validate_processors(
        %Pczone.Motherboard{
          id: motherboard_id,
          processor_slots: [%Pczone.ProcessorSlot{} = slot]
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

  def validate_memories(%Pczone.Motherboard{memory_slots: memory_slots}, memories) do
    memory_slots_map = get_slots_map(memory_slots)
    memories_map = Repo.all(from(m in Pczone.Memory, select: {m.id, m})) |> Enum.into(%{})

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
        %Pczone.Motherboard{m2_slots: m2_slots, sata_slots: sata_slots},
        hard_drives
      ) do
    m2_slots_map = get_slots_map(m2_slots)
    sata_slots_map = get_slots_map(sata_slots)
    slots_map = Map.merge(m2_slots_map, sata_slots_map)
    hard_drives_map = Repo.all(from(m in Pczone.HardDrive, select: {m.id, m})) |> Enum.into(%{})

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

  def validate_gpus(%Pczone.Motherboard{pci_slots: pci_slots}, gpus) do
    pci_slots_map = get_slots_map(pci_slots)
    gpus_map = Repo.all(from(m in Pczone.Gpu, select: {m.id, m})) |> Enum.into(%{})

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

  def parse_filter(filter) do
    filter
    |> Enum.reduce(nil, fn {field, value}, acc ->
      case field do
        :name -> parse_string_filter(acc, field, value)
        :built_template_id -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
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
