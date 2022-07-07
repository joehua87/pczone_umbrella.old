defmodule PcZoneWeb.Middlewares.ErrorsHandle do
  @behaviour Absinthe.Middleware
  def call(resolution, _) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  defp get_message(_errors = [{msg, opts} | _]) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, opts} -> {message, opts} end)
    |> Enum.map(fn {field, errors} ->
      %{
        message: "#{field} #{get_message(errors)}",
        field: field,
        details:
          Enum.map(errors, fn {msg, opts} ->
            %{msg: msg, opts: Enum.into(opts, %{})}
          end)
      }
    end)
  end

  defp handle_error(errors) when is_map(errors) do
    errors
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end

  defp handle_error(error), do: [error]
end
