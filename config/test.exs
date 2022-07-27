import Config

config :pczone,
  report_dir: "/Users/achilles/pczone/reports",
  media_dir: "/Users/achilles/pczone/media"

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :pczone, Pczone.Repo,
  username: "postgres",
  password: "postgres",
  database: "pczone_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :pczone, Pczone.MongoRepo,
  url: System.get_env("MONGO_URL", "mongodb://localhost:27017/pczone"),
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pczone_web, PczoneWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Mwl1VghP/uiYUeE5nzUrd8ZQ/pGcskPcCgyqVAkRc/lCr4bkDy4Q1WBkE/uD6Il6",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :pczone, Pczone.Mailer, adapter: Swoosh.Adapters.Test

config :goth, disabled: true

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
