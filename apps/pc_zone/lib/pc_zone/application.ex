defmodule PcZone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      PcZone.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: PcZone.PubSub},
      {Mongo, PcZone.MongoRepo.config()},
      {Finch, name: MyFinch}
      # Start a worker by calling: PcZone.Worker.start_link(arg)
      # {PcZone.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: PcZone.Supervisor)
  end
end
