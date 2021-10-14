defmodule Exbin.MixProject do
  use Mix.Project

  def project do
    [
      app: :exbin,
      version: "0.1.6-dev.5",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      default_release: :prod,
      releases: [
        prod: [
          overlays: "rel/overlays"
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Exbin.Application, []},
      extra_applications: [:logger, :runtime_tools, :ex_rated, :swoosh, :gen_smtp]
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
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:horsestaplebattery, "~> 0.1.0"},
      {:timex, "~> 3.7"},
      {:parent, "~> 0.12.0"},
      {:ex_rated, "~> 2.0"},
      {:phoenix_live_view, "~> 0.15.7"},
      {:phx_gen_auth, "~> 0.7", only: [:dev], runtime: false},
      {:swoosh, "~> 1.5"},
      {:gen_smtp, "~> 1.0"},
      {:sizeable, "~> 1.0"},
      {:cachex, "~> 3.4"},
      {:hammer, "~> 6.0"},
      {:hammer_plug, "~> 2.1"}
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
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
