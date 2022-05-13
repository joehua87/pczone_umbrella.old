defmodule Xeon.Barebones do
  def create(%{
        motherboard: motherboard,
        chassis: chassis,
        psu: psu,
        barebone: barebone
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:motherboard, Xeon.Motherboard.new_changeset(motherboard))
    |> Ecto.Multi.insert(:chassis, Xeon.Chassis.new_changeset(chassis))
    |> Ecto.Multi.insert(:psu, Xeon.Psu.new_changeset(psu))
    |> Ecto.Multi.run(
      :barebone,
      fn _,
         %{
           motherboard: %{id: motherboard_id},
           chassis: %{id: chassis_id},
           psu: %{id: psu_id}
         } ->
        barebone
        |> Map.merge(%{
          motherboard_id: motherboard_id,
          chassis_id: chassis_id,
          psu_id: psu_id
        })
        |> Xeon.Barebone.new_changeset()
        |> Xeon.Repo.insert()
      end
    )
    |> Xeon.Repo.transaction()
  end

  def parse(:hardware_corner, data, opts) do
    motherboard = parse_motherboard(:hardware_corner, data, opts)
    chassis = parse_chassis(:hardware_corner, data)
    psu = parse_psu(:hardware_corner, data)
    barebone = parse_barebone(:hardware_corner, data)

    %{
      motherboard: motherboard,
      chassis: chassis,
      psu: psu,
      barebone: barebone
    }
  end

  defp parse_barebone(
         :hardware_corner,
         %{"title" => name, "fieldValues" => field_values}
       ) do
    weight = get_field_value(field_values, "Weight")
    %{name: name, weight: weight}
  end

  defp parse_motherboard(
         :hardware_corner,
         %{"title" => name, "fieldValues" => field_values},
         chipsets_map: chipsets_map
       ) do
    chipset = get_field_value(field_values, "Chipset")
    chipset_id = chipsets_map[chipset]
    memory_slots = get_field_value(field_values, "RAM slots") |> String.to_integer()

    max_memory_capacity =
      get_field_value(field_values, "RAM max") |> String.replace(" GB", "") |> String.to_integer()

    memory_types = Xeon.MemoryTypes.get(:hardware_corner, get_field_value(field_values, "RAM"))

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      processor_slots: [
        %{
          slots: 1
        }
      ],
      memory_slots: [
        %{
          types: memory_types,
          slots: memory_slots
        }
      ],
      sata_slots: [
        %{
          slots: 1
        }
      ],
      m2_slots: [
        %{
          slots: 1
        }
      ],
      pci_slots: [
        %{
          slots: 0
        }
      ],
      attributes: [],
      processor_slots_count: 1,
      memory_slots_count: memory_slots,
      max_memory_capacity: max_memory_capacity
    }
  end

  defp parse_psu(:hardware_corner, %{"title" => name, "fieldValues" => field_values}) do
    wattage = get_field_value(field_values, "PSU")

    %{
      name: name,
      wattage: wattage
      # type: "virtual"
    }
  end

  defp parse_chassis(:hardware_corner, %{"title" => name, "fieldValues" => field_values}) do
    form_factor = get_field_value(field_values, "Form factor")

    %{
      name: name,
      form_factor: form_factor
    }
  end

  defp get_field_value(field_values, label) do
    case Enum.find(field_values, &(&1["label"] == label)) do
      nil -> nil
      %{"value" => value} -> value
    end
  end
end
