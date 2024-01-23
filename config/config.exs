import Config

config :exbin,
  ecto_repos: [Exbin.Repo]

# Configures the endpoint
config :exbin, ExbinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "L2jznV0Pu2SuhkCPqBWKIxk0PGZW27e6MeB2FCP6akYpm/nlKGx49mnKrZGvlS0X",
  render_errors: [view: ExbinWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Exbin.PubSub,
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
  tcp_host: {0, 0, 0, 0},
  base_url: "http://localhost:4000",
  max_size: 2048,
  timezone: "Europe/Brussels",
  apikey: "devkey",
  brand: "Exbin Development"

# Viewcount rate limit configuration.
config :ex_rated,
  timeout: 86_400_000,
  cleanup_rate: 10_000,
  persistent: false

config :swoosh, :api_client, false

# Rate limiting
config :hammer,
  backend:
    {Hammer.Backend.ETS,
     [
       # 24 hour
       expiry_ms: 60_000 * 60 * 4,
       # 10 minutes
       cleanup_interval_ms: 60_000 * 10
     ]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
