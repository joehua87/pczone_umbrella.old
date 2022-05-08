defmodule Xeon.Builts do
  import Ecto.Query, only: [from: 2]
  alias Xeon.{Repo, Motherboard, Memory, Processor, ProcessorChipset}

  def get_processors(motherboard_id) do
    %{chipset_id: chipset_id} = Repo.get(Motherboard, motherboard_id)

    processor_ids_query =
      from pc in ProcessorChipset,
        where: pc.chipset_id == ^chipset_id,
        select: pc.processor_id

    Repo.all(from p in Processor, where: p.id in subquery(processor_ids_query))
  end

  def get_memories(motherboard_id) do
    %{memory_types: memory_types} = Repo.get(Motherboard, motherboard_id)
    Repo.all(from m in Memory, where: m.type in ^memory_types)
  end
end
