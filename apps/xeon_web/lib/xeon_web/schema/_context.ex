defmodule XeonWeb.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    {user_id, role} =
      case conn.assigns.user do
        nil -> {nil, nil}
        %{"id" => id, "role" => role} -> {id, role}
      end

    website_id = Map.get(conn.assigns, :website_id)
    order_token = Map.get(conn.assigns, :order_token)

    %{
      website_id: website_id,
      user_id: user_id,
      order_token: order_token,
      role: role && String.to_existing_atom(role)
    }
  end
end
