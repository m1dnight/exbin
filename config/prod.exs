use Mix.Config

config :exbin, :brand, (System.get_env("BRAND") || "ExBin")

config :exbin, ExBinWeb.Endpoint,
  load_from_system_env: true,
  url: [
    host: "example.com",
    port: String.to_integer(System.get_env("PORT") || "4001")
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :exbin, ExBinWeb.Endpoint, secret_key_base: "TVMx0s2diEXeLKEJ0NF34BttjGVol3On4Yd4dM8XfgplgF3Y6sq3PxBRzp26/Gf6"

# Configure your database
config :exbin, ExBin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "user",
  password: System.get_env("DB_PASS") || "pass",
  database: System.get_env("DB_NAME") || "exbindb",
  hostname: System.get_env("DB_HOST") || "localhost",
  pool_size: 10

config :exbin, ExBinWeb.Endpoint,
  load_from_system_env: true,
  url: [
    host: System.get_env("EXTERNAL_URL") || "localhost",
    port: String.to_integer(System.get_env("PORT") || "4001")
  ]
