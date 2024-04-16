defmodule ImpactTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :impact_tracker,
      version: "0.4.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: [
        verify: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ImpactTracker.Application, []},
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
      {:credo, "~> 1.7.3", only: [:test, :dev]},
      {:dialyxir, "~> 1.4.3", only: [:test, :dev], runtime: false},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_sql, "~> 3.10"},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:excoveralls, "~> 0.18.0", only: [:test, :dev]},
      {:finch, "~> 0.13"},
      {:geoip, "~> 0.2.8"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3.8", only: [:test]},
      {:oban, "~> 2.17"},
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:postgrex, ">= 0.0.0"},
      {:plug_cowboy, "~> 2.5"},
      {:remote_ip, "~> 1.1"},
      {:sobelow, "~> 0.13.0", only: [:test, :dev]},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      verify: [
        "coveralls.html",
        "format --check-formatted",
        "dialyzer",
        "credo --strict --all",
        "sobelow"
      ]
    ]
  end
end
