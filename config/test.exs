import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :exbin, Exbin.Repo,
  username: "postgres",
  password: "postgres",
  database: "exbin_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exbin, ExbinWeb.Endpoint,
  http: [port: 4002],
  server: false

# Allow TCP server to start in test env by running on a different port.
# This is a quick hack. We could also alter the supervisor to only run
# run it in specific environments.
config :exbin,
  tcp_port: 9998

# In this env Clock freezing is allowed
config :exbin, Exbin.Clock, freezable: true

# Print only warnings and errors during test
config :logger, level: :warning
