use Mix.Config

config :exbin, ExBinWeb.Endpoint,
  http: [port: 4001],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :exbin, ExBinWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/exbin_web/views/.*(ex)$},
      ~r{lib/exbin_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :exbin, ExBin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "exbin",
  password: System.get_env("DB_PASS") || "exbin",
  database: System.get_env("DB_NAME") || "exbindb",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool_size: 10
