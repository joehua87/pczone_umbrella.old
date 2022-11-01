defmodule PczoneWeb.Context do
  import Plug.Conn

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    user = fetch_current_user(conn)

    %{
      user: user,
      user_id: Map.get(user, :id),
      order_token: fetch_order_token(conn)
    }
  end

  defp fetch_current_user(conn) do
    case get_req_header(conn, "user-token") do
      [token | _] -> Base.decode64!(token) |> Pczone.Users.get_user_by_session_token()
      _ -> nil
    end
  end

  defp fetch_order_token(conn) do
    case get_req_header(conn, "order-token") do
      [order_token | _] -> order_token
      _ -> nil
    end
  end
end
