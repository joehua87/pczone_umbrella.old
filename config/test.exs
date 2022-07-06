import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :pc_zone, PcZone.Repo,
  username: "postgres",
  password: "postgres",
  database: "pc_zone_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :pc_zone, PcZone.MongoRepo,
  url: "mongodb://localhost:27017/pc_zone",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pc_zone_web, PcZoneWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Mwl1VghP/uiYUeE5nzUrd8ZQ/pGcskPcCgyqVAkRc/lCr4bkDy4Q1WBkE/uD6Il6",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :pc_zone, PcZone.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
