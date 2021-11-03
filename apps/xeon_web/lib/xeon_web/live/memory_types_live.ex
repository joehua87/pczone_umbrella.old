defmodule XeonWeb.MemoryTypesLive do
  use XeonWeb, :live_view
  alias Xeon.{Repo, Chipset, MemoryType}

  def handle_params(params, _uri, socket) do
    {:noreply, socket |> load_data(params)}
  end

  def handle_event("create", params, socket) do
    with {:ok, _chipset} <-
           %MemoryType{}
           |> MemoryType.changeset(params)
           |> Repo.insert() do
      {:noreply, socket}
    end
    |> IO.inspect()
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= for entity <- @chipsets do %>
        <form phx-submit="create">
          <div><%= entity.id %></div>
          <div><%= entity.name %></div>
          <input name="name" placeholder="name" />
          <input type="number" name="max_memory_capacity" placeholder="Max memory capacity" />
          <input type="number" name="memory_slot" placeholder="Memory slot" />
          <input type="number" name="processor_slot" placeholder="Processor slot" />
          <input name="chipset_id" type="hidden" value={entity.id} />
          <button>Create</button>
        </form>
      <% end %>
      <%= for entity <- @entities do %>
        <div>
          <div><%= entity.name %></div>
          <div>max_memory_capacity: <%= entity.max_memory_capacity %></div>
          <div>memory_slot: <%= entity.memory_slot %></div>
          <div>processor_slot: <%= entity.processor_slot %></div>
        </div>
      <% end %>

    </div>
    """
  end

  defp load_data(socket, _params) do
    chipsets = Repo.all(Chipset)
    entities = Repo.all(MemoryType)
    socket |> assign(%{entities: entities, chipsets: chipsets})
  end
end
