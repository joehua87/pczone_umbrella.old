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
  ecto_repos: [PcZone.Repo],
  sheet_id: "1gqCHoE7dVKAcRoKhMvJjlNaozDpQGGTN_YDfE4QBfb0"

config :pczone, PcZone.MongoRepo,
  url: "mongodb://172.16.43.5:27017/pczone",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

config :pczone, PcZone.Repo, types: PcZone.PostgresTypes
# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pczone, PcZone.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :pczone_web,
  ecto_repos: [PcZone.Repo],
  generators: [context_app: :pczone]

# Configures the endpoint
config :pczone_web, PcZoneWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PcZoneWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PcZone.PubSub,
  live_view: [signing_salt: "FG3Ddexk"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(src/app.ts --bundle --target=es2016 --loader:.woff=file --loader:.woff2=file --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/pczone_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
