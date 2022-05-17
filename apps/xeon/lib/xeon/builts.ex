defmodule Xeon.Builts do
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Motherboard, Memory, Processor, ProcessorChipset}

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
      from(mp in Xeon.MotherboardProcessor,
        where: mp.motherboard_id == ^motherboard_id,
        select: mp.processor_id
      )

    if Repo.aggregate(processor_ids_query, :count) > 0 do
      processor_ids_query
    else
      %{chipset_id: chipset_id} = Repo.get(Motherboard, motherboard_id)

      from(pc in ProcessorChipset,
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
    %{memory_types: memory_types} = Repo.get(Motherboard, motherboard_id)
    Repo.all(from(m in Memory, where: m.type in ^memory_types))
  end

  def create(%{barebone_id: barebone_id}) when is_bitstring(barebone_id) do
  end

  def create(%{
        motherboard_id: motherboard_id,
        processors: _,
        memories: _
      })
      when is_bitstring(motherboard_id) do
  end

  def validate_chassis(
        %Xeon.Motherboard{chassis_form_factors: chassis_form_factors},
        %Xeon.Chassis{form_factor: form_factor}
      ) do
    if Enum.member?(chassis_form_factors, form_factor),
      do: :ok,
      else: {:error, "Invalid chassis form factor"}
  end

  def validate_psus(%Xeon.Chassis{}, [_ | _]) do
    {:error, "Only support built with 1 psu now"}
  end

  def validate_psus(%Xeon.Chassis{psu_form_factors: psu_form_factors}, [%{psu_id: psu_id}]) do
    case Repo.get(Xeon.Psu, psu_id) do
      %Xeon.Psu{form_factor: form_factor} ->
        if Enum.member?(psu_form_factors, form_factor),
          do: :ok,
          else: {:error, "Invalid psu form factor"}

      nil ->
        {:error, {"Invalid psu id", psu_id: psu_id}}
    end
  end

  def validate_extension_devices(%Xeon.ExtensionDevice{}, _extension_devices) do
  end

  def validate_processors(%Xeon.Motherboard{processor_slots: processor_slots}, processors)
      when length(processor_slots) != 1 or length(processors) != 1 do
    {:error, "Only support motherboard which has 1 processor type"}
  end

  def validate_processors(
        %Xeon.Motherboard{id: motherboard_id, processor_slots: [%Xeon.ProcessorSlot{} = slot]},
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

  def validate_memories(%Xeon.Motherboard{memory_slots: memory_slots}, memories) do
    memory_slots_map =
      Enum.map(
        memory_slots,
        fn %Xeon.MemorySlot{type: type, processor_index: processor_index} = slot ->
          {"#{type}:#{processor_index}", slot}
        end
      )
      |> Enum.into(%{})

    memories_map = Repo.all(from m in Xeon.Memory, select: {m.id, m}) |> Enum.into(%{})

    errors =
      memories
      |> Enum.map(fn %{
                       memory_id: memory_id,
                       processor_index: processor_index,
                       slot_type: slot_type
                     } ->
        memory = memories_map[memory_id]

        %{
          supported_types: supported_types,
          max_capacity: max_capacity
        } = memory_slots_map["#{slot_type}:#{processor_index}"]

        if Enum.member?(supported_types, memory.type) do
          if max_capacity >= memory.capacity do
            :ok
          else
            {:error,
             {"Motherboard does not support memory capacity more than {capacity}",
              capacity: max_capacity}}
          end
        else
          {:error,
           {"Motherboard does not support memory type {memory_type}", memory_type: memory.type}}
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

  def validate_memories(
        %Xeon.Motherboard{memory_slots: memory_slots},
        [
          %{memory_id: memory_id, type: type, quantity: quantity}
        ]
      ) do
    []
  end

  def validate_gpus(%Xeon.Motherboard{pci_slots: pci_slots}, gpus) do
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
end
