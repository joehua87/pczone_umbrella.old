import Config

get_env = fn name, example ->
  System.get_env(name) ||
    raise """
    environment variable #{name} is missing.
    For example: #{example}
    """
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  config :pczone,
    report_dir: get_env.("REPORTS_DIR", "/mnt/reports"),
    media_dir: get_env.("MEDIA_DIR", "/mnt/media"),
    media_dir: get_env.("SOURCE_MEDIA_DIR", "/hdd-pool/pczone-data/product-images/pczone")

  config :pczone, Pczone.Repo,
    # ssl: true,
    # socket_options: [:inet6],
    url: get_env.("DATABASE_URL", "ecto://USER:PASS@HOST/DATABASE"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :pczone, Pczone.MongoRepo,
    url: get_env.("MONGO_URL", "mongodb://USER:PASS@HOST/MONGO"),
    timeout: 60_000,
    idle_interval: 10_000,
    queue_target: 5_000

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :pczone_web, PczoneWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  config :pczone_web, PczoneWeb.Endpoint, server: true

  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :pczone, Pczone.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
