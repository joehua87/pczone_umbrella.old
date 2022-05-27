defmodule Xeon.MixProject do
  use Mix.Project

  def project do
    [
      app: :xeon,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Xeon.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dew_util, "~> 0.2"},
      {:ecto_ltree, "~> 0.4.0"},
      {:nimble_csv, "~> 1.1"},
      {:finch, "~> 0.9.0"},
      {:floki, "~> 0.32.0"},
      {:mongodb_driver, "~> 0.9.0"},
      {:mime, "~> 2.0", override: true},
      {:recase, "~> 0.7"},
      {:slugify, "~> 1.3"},
      {:scrivener_ecto, "~> 2.7"},
      {:tesla, "~> 1.4"},
      {:yaml_elixir, "~> 2.9"},
      {:google_api_sheets, "~> 0.29"},
      {:goth, "~> 1.2.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:swoosh, "~> 1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
