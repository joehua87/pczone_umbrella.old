defmodule PcZoneWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PcZoneWeb.Telemetry,
      # Start the Endpoint (http/https)
      PcZoneWeb.Endpoint
      # Start a worker by calling: PcZoneWeb.Worker.start_link(arg)
      # {PcZoneWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PcZoneWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PcZoneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
