# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :pczone,
  ecto_repos: [Pczone.Repo],
  sheet_id: "1gqCHoE7dVKAcRoKhMvJjlNaozDpQGGTN_YDfE4QBfb0"

config :pczone, Pczone.Repo,
  types: Pczone.PostgresTypes,
  migration_timestamps: [type: :utc_datetime]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pczone, Pczone.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :pczone_web,
  ecto_repos: [Pczone.Repo],
  generators: [context_app: :pczone]

# Configures the endpoint
config :pczone_web, PczoneWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PczoneWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pczone.PubSub,
  live_view: [signing_salt: "FG3Ddexk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nanoid,
  size: 21,
  alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
