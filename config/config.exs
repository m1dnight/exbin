# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :exbin,
  ecto_repos: [ExBin.Repo]

# Configures the endpoint
config :exbin, ExBinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "L2jznV0Pu2SuhkCPqBWKIxk0PGZW27e6MeB2FCP6akYpm/nlKGx49mnKrZGvlS0X",
  render_errors: [view: ExBinWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExBin.PubSub,
  live_view: [signing_salt: "EubGfePc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# The default view for a snippet.
# Can be :code, :reader, or :raw.
config :exbin,
  default_view: :code,
  ephemeral_age: 60,
  tcp_port: 9999,
  tcp_host: (System.get_env("TCP_HOST") || "127.0.0.1") |> to_charlist() |> :inet.parse_address() |> elem(1),
  base_url: "http://localhost:4000",
  max_size: 2048

# Viewcount rate limit configuration.
config :ex_rated,
  timeout: 86_400_000,
  cleanup_rate: 10_000,
  persistent: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
