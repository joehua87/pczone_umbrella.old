defmodule Pczone.Helpers do
  def ensure_slug(%{slug: "" <> _} = params), do: params
  def ensure_slug(%{"slug" => "" <> _} = params), do: params
  def ensure_slug(%{name: name} = params), do: Map.put(params, :slug, Slug.slugify(name))
  def ensure_slug(%{"name" => name} = params), do: Map.put(params, "slug", Slug.slugify(name))

  def get_list_changset_changes(list, func) do
    Enum.reduce(list, [], fn
      _, {:error, _} = error ->
        error

      entity, list ->
        case func.(entity) do
          {:error, changeset} -> {:error, changeset}
          entity -> list ++ [entity]
        end
    end)
  end

  def get_changeset_changes(%Ecto.Changeset{changes: changes, valid?: true}) do
    for {key, value} <- changes, into: %{} do
      case value do
        %Ecto.Changeset{data: data} ->
          {key, Map.merge(data, get_changeset_changes(value))}

        [%Ecto.Changeset{data: data} | _] ->
          {key, Enum.map(value, &Map.merge(data, get_changeset_changes(&1)))}

        _ ->
          {key, value}
      end
    end
  end

  def get_changeset_changes(changeset = %Ecto.Changeset{valid?: false}) do
    {:error, changeset}
  end

  @doc """
  Read data from a csv, json or yaml file, return a Map or a list of Map
  """
  def read_data(file, default \\ []) do
    cond do
      String.match?(file, ~r/\.ya?ml/) -> YamlElixir.read_from_file!(file)
      String.match?(file, ~r/\.xlsx/) -> Pczone.Xlsx.read_spreadsheet(file)
      String.match?(file, ~r/\.json/) -> file |> File.read!() |> Jason.decode!()
      true -> default
    end
  end

  def get_attribute_value(attributes, group, label) do
    attributes
    |> Enum.find(&(&1["group"] == group))
    |> case do
      nil -> nil
      %{"items" => items} -> get_value(items, label)
    end
  end

  def extract_attributes(attributes, list) do
    list
    |> Enum.reduce(%{}, fn item = %{key: key, group: group, label: label}, acc ->
      transform = Map.get(item, :transform)
      value = get_attribute_value(attributes, group, label)
      Map.put(acc, key, if(transform, do: transform.(value), else: value))
    end)
  end

  def parse_attributes(attributes) do
    Enum.map(attributes, fn %{"group" => group, "items" => items} ->
      %Pczone.AttributeGroup{
        title: group,
        items:
          Enum.map(
            items,
            &%Pczone.AttributeGroup.Attribute{
              label: &1["label"],
              value: &1["value"]
            }
          )
      }
    end)
  end

  def parse_launch_date(value) do
    [q, y] = value |> String.split("'")
    "20#{y}-#{q}"
  end

  def parse_temperuture(nil) do
    nil
  end

  def parse_temperuture(value) do
    case value do
      nil ->
        nil

      "." ->
        nil

      "" <> temp ->
        temp
        |> String.replace("°", "")
        |> String.replace("C", "")
        |> String.trim()
        |> Decimal.new()
    end
  end

  def parse_integer(value, suffix \\ "")

  def parse_integer(nil, _) do
    nil
  end

  def parse_integer("" <> value, suffix) do
    String.replace(value, suffix, "") |> String.to_integer()
  end

  def parse_frequency(nil) do
    nil
  end

  def parse_frequency("" <> value) do
    cond do
      String.contains?(value, " MHz") -> parse_decimal(value, " MHz")
      String.contains?(value, " GHz") -> parse_decimal(value, " GHz") |> Decimal.mult(1000)
      true -> nil
    end
  end

  def parse_decimal(nil, _) do
    nil
  end

  def parse_decimal("" <> value, suffix) do
    String.replace(value, suffix, "") |> Decimal.new()
  end

  defp get_value(items, label) do
    items
    |> Enum.find(&(&1["label"] == label))
    |> case do
      nil -> nil
      %{"value" => value} -> value
    end
  end
end
