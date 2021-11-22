defmodule XeonWeb.ProcessorsLive do
  use XeonWeb, :live_view
  alias Xeon.{Repo, Processor}

  def handle_params(params, _uri, socket) do
    {:noreply, socket |> load_data(params)}
  end

  def handle_event("create", params, socket) do
    with {:ok, _chipset} <- Processor.changeset(%Processor{}, params) |> Repo.insert() do
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= for entity <- @entities do %>
        <div><%= entity.name %></div>
        <div><%= entity.cores %></div>
        <div><%= entity.family_code %></div>
        <div><%= entity.threads %></div>
        <div><%= entity.frequency %></div>
        <div><%= entity.maximum_frequency %></div>
        <div><%= entity.socket %></div>
        <div><%= entity.gpu %></div>
        <div>TDP: <%= entity.tdp %></div>
      <% end %>
    </div>
    """
  end

  defp load_data(socket, _params) do
    entities = Repo.all(Processor)
    socket |> assign(%{entities: entities})
  end
end
