defmodule Xeon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Xeon.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Xeon.PubSub},
      {Finch, name: MyFinch}
      # Start a worker by calling: Xeon.Worker.start_link(arg)
      # {Xeon.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Xeon.Supervisor)
  end
end
