defmodule Xeon.Motherboards do
  alias Ecto.Multi
  import Dew.FilterParser
  import Ecto.Query, only: [from: 2, where: 2]

  alias Xeon.{
    Repo,
    ProcessorCollection,
    Motherboard,
    MotherboardProcessorCollection,
    Helpers.GoogleSheets
  }

  def get(id) do
    Repo.get(Motherboard, id)
  end

  def list(attrs \\ %{})

  def list(%Dew.Filter{
        filter: filter,
        paging: paging,
        selection: selection,
        order_by: order_by
      }) do
    Motherboard
    |> where(^parse_filter(filter))
    |> select_fields(selection, [:attributes])
    |> sort_by(order_by, [])
    |> Repo.paginate(paging)
  end

  def list(attrs = %{}), do: list(struct(Dew.Filter, attrs))

  def import_barebone_motherboards() do
    {:ok, conn} = Mongo.start_link(url: "mongodb://172.16.43.5:27017/xeon")

    cursor =
      Mongo.find(conn, "Product", %{
        "fieldValues.0" => %{"$exists" => true}
      })

    chipsets_map = Repo.all(from c in Xeon.Chipset, select: {c.shortname, c.id}) |> Enum.into(%{})

    motherboards =
      Enum.map(cursor, &parse(&1, chipsets_map: chipsets_map))
      |> Enum.filter(&(&1.chipset_id != nil))
      |> Enum.map(&Map.delete(&1, :chipset))

    Repo.insert_all(Xeon.Motherboard, motherboards)
  end

  defp parse(%{"title" => name, "fieldValues" => field_values}, chipsets_map: chipsets_map) do
    chipset = get_field_value(field_values, "Chipset")
    chipset_id = chipsets_map[chipset]
    memory_slots = get_field_value(field_values, "RAM slots") |> String.to_integer()

    max_memory_capacity =
      get_field_value(field_values, "RAM max") |> String.replace(" GB", "") |> String.to_integer()

    memory_types =
      %{
        "DIMM DDR3-1333" => ["DIMM DDR3-1333"],
        "DIMM DDR3-1333/1600" => ["DIMM DDR3-1333", "DIMM DDR3-1600"],
        "DIMM DDR3-1600" => ["DIMM DDR3-1600"],
        "SODIMM DDR3-1600" => ["SODIMM DDR3-1600"],
        "DIMM DDR3L-1600" => ["DIMM DDR3L-1600"],
        "SODIMM DDR3L-1600" => ["SODIMM DDR3L-1600"],
        "DIMM DDR4-2133/2400" => ["DIMM DDR4-2133", "DIMM DDR4-2400"],
        "SODIMM DDR4-2133/2400" => ["SODIMM DDR4-2133", "SODIMM DDR4-2400"],
        "DIMM DDR4-2400/2666" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
        "SODIMM DDR4-2400/2666" => ["SODIMM DDR4-2400", "SODIMM DDR4-2666"],
        "DIMM DDR4-2666" => ["DIMM DDR4-2666"],
        "SODIMM DDR4-2666" => ["SODIMM DDR4-2666"],
        "DIMM DDR4-2666/2933" => ["DIMM DDR4-2666", "DIMM DDR4-2933"],
        "SODIMM DDR4-2666/2933" => ["SODIMM DDR4-2666", "SODIMM DDR4-2933"],
        "DIMM DDR4-2666/2933/3200" => ["DIMM DDR4-2666", "DIMM DDR4-2933", "DIMM DDR4-3200"],
        "DIMM DDR4-2133" => ["DIMM DDR4-2133"],
        "SODIMM DDR4-2133" => ["SODIMM DDR4-2133"],
        "SODIMM-2133/2400" => ["SODIMM-2133", "SODIMM-2400"],
        "DIMM DDR3-1060/1333" => ["DIMM DDR3-1060", "DIMM DDR3-1333"],
        "DIMM DDR3-1333/1866" => ["DIMM DDR3-1333", "DIMM DDR3-1866"],
        "DIMM DDR4-2400/2667" => ["DIMM DDR4-2400", "DIMM DDR4-2666"],
        "DIMM DDR4-2666/3000" => ["DIMM DDR4-2666", "DIMM DDR4-3000"],
        "DIMM DDR4-2933/3400" => ["DIMM DDR4-2933", "DIMM DDR4-3400"],
        "DIMM DDR4-3200/3400" => ["DIMM DDR4-3200", "DIMM DDR4-3400"],
        "DIMM DDR4-4400" => ["DIMM DDR4-4400"],
        "DIMM DDR3-2133" => ["DIMM DDR3-2133"],
        "DIMM DDR4-2133/2667" => ["DIMM DDR4-2133", "DIMM DDR4-2667"],
        "DIMM DDR4-2666/3200" => ["DIMM DDR4-2666", "DIMM DDR4-3200"],
        "SO-DIMM DDR3-1333" => ["SODIMM DDR3-1333"],
        "DIMM DDR4-2400" => ["DIMM DDR4-2400"],
        "DIMM DDR3-2133/2400" => ["DIMM DDR3-2133", "DIMM DDR3-2400"],
        "SODIMM DDR4-2400" => ["SODIMM DDR4-2400"],
        "SODIMM DDR4-2933" => ["SODIMM DDR4-2933"],
        "DIMM DDR4-2933" => ["DIMM DDR4-2933"],
        "SODIMM DDR4-3200" => ["SODIMM DDR4-3200"],
        "DIMM DDR4-3200" => ["DIMM DDR4-3200"],
        "SDIMM DDR3-1600" => ["SODIMM DDR3-1600"]
      }[get_field_value(field_values, "RAM")]

    %{
      name: name,
      chipset: chipset,
      chipset_id: chipset_id,
      memory_types: memory_types,
      memory_slots: memory_slots,
      processor_slots: 1,
      max_memory_capacity: max_memory_capacity,
      hard_drive_slots: [],
      pci_slots: [],
      attributes: []
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
        :id -> parse_id_filter(acc, field, value)
        :name -> parse_string_filter(acc, field, value)
        _ -> acc
      end
    end) || true
  end
end
