defmodule Pczone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Pczone.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pczone.PubSub},
      {Mongo, Pczone.MongoRepo.config()},
      {Finch, name: MyFinch}
      # Start a worker by calling: Pczone.Worker.start_link(arg)
      # {Pczone.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Pczone.Supervisor)
  end
end
