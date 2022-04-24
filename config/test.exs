import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :xeon, Xeon.Repo,
  username: "postgres",
  password: "postgres",
  database: "xeon_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "dev.local",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :xeon_web, XeonWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Mwl1VghP/uiYUeE5nzUrd8ZQ/pGcskPcCgyqVAkRc/lCr4bkDy4Q1WBkE/uD6Il6",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :xeon, Xeon.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
