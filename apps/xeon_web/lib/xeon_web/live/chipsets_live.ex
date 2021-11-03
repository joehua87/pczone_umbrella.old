defmodule XeonWeb.ChipsetsLive do
  use XeonWeb, :live_view
  alias Xeon.{Repo, Chipset}

  def handle_params(params, _uri, socket) do
    {:noreply, socket |> load_data(params)}
  end

  def handle_event("create", params, socket) do
    with {:ok, _chipset} <- Chipset.changeset(%Chipset{}, params) |> Repo.insert() do
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= for entity <- @entities do %>
        <div><%= entity.name %></div>
      <% end %>
      <form phx-submit="create">
        <input name="name" />
        <button>Create</button>
      </form>
    </div>
    """
  end

  defp load_data(socket, _params) do
    entities = Repo.all(Chipset)
    socket |> assign(%{entities: entities})
  end
end
