import Config

config :pczone,
  report_dir: "/Users/achilles/pczone/reports",
  media_dir: "/Users/achilles/pczone/media"

db_config =
  if url = System.get_env("DEV_DATABASE_URL") do
    [url: url]
  else
    [
      username: "postgres",
      password: "postgres",
      database: "pczone_dev",
      hostname: "localhost",
      port: 5432
    ]
  end ++
    [
      show_sensitive_data_on_connection_error: true,
      pool_size: 10
    ]

# Configure your database
config :pczone, Pczone.Repo, db_config

config :pczone, Pczone.MongoRepo,
  url: "mongodb://localhost:27017/xeon",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

# For development, we disable any cache and enable
# debugging and code reloading.
config :pczone_web, PczoneWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "4tOuf5HcdWLq8prYZKvd5OwRK+0EtEL6ZIo/0nu4+cGEEsIDb+B2PjJ94MoA11Xl",
  watchers: []

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :pczone_web, PczoneWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/pczone_web/(live|views)/.*(ex)$",
      ~r"lib/pczone_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :logger, level: :info
