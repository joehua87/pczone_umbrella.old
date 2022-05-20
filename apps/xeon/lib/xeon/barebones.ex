defmodule Xeon.Barebones do
  require Logger
  import Ecto.Query, only: [where: 2]
  import Dew.FilterParser
  alias Xeon.{Repo, Barebone}

  def get(id) do
    Repo.get(Barebone, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Barebone
    |> where(^parse_filter(filter))
    |> select_fields(selection, [])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def upsert(entities, opts \\ []) do
    brands_map = Xeon.Brands.get_map_by_slug()
    motherboards_map = Xeon.Motherboards.get_map_by_slug()
    psus_map = Xeon.Psus.get_map_by_slug()
    chassises_map = Xeon.Chassises.get_map_by_slug()

    entities =
      Enum.map(
        entities,
        &parse_entity_for_upsert(&1,
          brands_map: brands_map,
          motherboards_map: motherboards_map,
          psus_map: psus_map,
          chassises_map: chassises_map
        )
      )

    Repo.insert_all(
      Barebone,
      entities,
      Keyword.merge(opts, on_conflict: :replace_all, conflict_target: [:slug])
    )
  end

  def parse_entity_for_upsert(params,
        brands_map: brands_map,
        motherboards_map: motherboards_map,
        psus_map: psus_map,
        chassises_map: chassises_map
      ) do
    case params do
      %{brand: brand} -> Map.put(params, :brand_id, brands_map[brand])
      %{"brand" => brand} -> Map.put(params, "brand_id", brands_map[brand])
    end
    |> case do
      params = %{psu: psu} -> Map.put(params, :psu_id, psus_map[psu])
      params = %{"psu" => psu} -> Map.put(params, "psu_id", psus_map[psu])
    end
    |> case do
      params = %{chassis: chassis} -> Map.put(params, :chassis_id, chassises_map[chassis])
      params = %{"chassis" => chassis} -> Map.put(params, "chassis_id", chassises_map[chassis])
    end
    |> case do
      params = %{motherboard: motherboard} ->
        Map.put(params, :motherboard_id, motherboards_map[motherboard])

      params = %{"motherboard" => motherboard} ->
        Map.put(params, "motherboard_id", motherboards_map[motherboard])
    end
    |> Xeon.Helpers.ensure_slug()
    |> Xeon.Barebone.new_changeset()
    |> Xeon.Helpers.get_changeset_changes()
  end

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
         %{
           "title" => name,
           "fieldValues" => field_values,
           "tables" => tables,
           "manualLink" => manual_link,
           "url" => source_url
         }
       ) do
    [weight | _] =
      get_field_value(field_values, "Weight") |> String.split(~r/kg/i) |> Enum.map(&String.trim/1)

    launch_date = get_field_value(field_values, "Released")
    psu_text = get_field_value(field_values, "PSU")

    psu_form_factor =
      cond do
        String.starts_with?(psu_text, "ATX") -> "ATX"
        String.starts_with?(psu_text, "TFX") -> "TFX"
        true -> nil
      end

    %{
      name: name,
      weight: Decimal.new(weight),
      launch_date: launch_date,
      psu_form_factor: psu_form_factor,
      source_url: source_url,
      source_website: URI.new!(source_url).host,
      raw_data: %{
        field_values: field_values,
        tables: tables,
        manual_link: manual_link
      }
    }
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

    {type, supported_types} =
      Xeon.MemoryTypes.get(:hardware_corner, get_field_value(field_values, "RAM"))

    m2_slots =
      get_field_value(field_values, "M.2 slots")
      |> String.split(";")
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&(!Enum.member?(["", "N.A."], &1)))

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      _m2_slots: m2_slots,
      processor_slots: [
        %{
          quantity: 1
        }
      ],
      memory_slots: [
        %{
          type: type,
          supported_types: supported_types,
          quantity: memory_slots
        }
      ],
      sata_slots: [
        %{
          quantity: 0
        }
      ],
      m2_slots: [
        %{
          quantity: 0
        }
      ],
      pci_slots: [
        %{
          quantity: 0
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
      form_factor: "custom",
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
