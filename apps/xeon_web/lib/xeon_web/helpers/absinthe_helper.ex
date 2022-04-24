defmodule XeonWeb.AbsintheHelper do
  alias Absinthe.Blueprint.Document.Field
  alias Absinthe.Blueprint.Document.Fragment.Spread
  alias Absinthe.Blueprint.Document.Fragment.Named

  @doc """
  Like `Absinthe.Resolution.project`, but return a tree like syntax
  """
  def project(info) do
    info
    |> Absinthe.Resolution.project()
    |> get_fields(info.fragments)
  end

  def get_fields(selections, fragments) when is_list(selections) do
    Enum.flat_map(selections, &get_field(&1, fragments))
  end

  defp get_field(%Field{name: "__typename"}, _fragments), do: []

  defp get_field(%Field{name: name, selections: []}, _fragments) do
    [{normalize_key(name), []}]
  end

  defp get_field(%Field{name: name, selections: selections}, fragments) do
    [{normalize_key(name), get_fields(selections, fragments)}]
  end

  defp get_field(%Spread{name: name}, fragments) do
    %Named{selections: selections} = fragments[name]
    get_fields(selections, fragments)
  end

  defp normalize_key(name) do
    name |> Recase.to_snake() |> String.to_existing_atom()
  end

  def get_query_hash(%{
        params: %{
          "extensions" => extensions,
          "operationName" => operationName,
          "variables" => variables
        }
      })
      when is_bitstring(extensions) do
    with {:ok, %{"persistedQuery" => %{"sha256Hash" => hash}}} <- Jason.decode(extensions) do
      %{
        "hash" => hash,
        "operationName" => operationName,
        # Hash variables
        "variables" => variables
      }

      hash
    end
  end

  def get_query_hash(_), do: nil
end
