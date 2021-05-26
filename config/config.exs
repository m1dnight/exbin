use Mix.Config

# The port on which the TCP server should listen.
config :exbin, :tcp_port, (System.get_env("TCP_PORT") || "9999") |> String.to_integer()

config :exbin, :default_view, (System.get_env("DEFAULT_VIEW") || "code")
config :exbin, :maximum_snippets_in_list, (System.get_env("PUBLIST_LIMIT") || nil)

# The ip to which the tcp server should bind.
config :exbin, :tcp_ip, (System.get_env("TCP_IP") || "127.0.0.1") |> to_charlist() |> :inet.parse_address() |> elem(1)

# General application configuration
config :exbin,
  ecto_repos: [ExBin.Repo]

# Configures the endpoint
config :exbin, ExBinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QTUmA1QFHVBkDuPSs30uWtJns/XEhCRNxrrIEzGrp9KyOQ4eGNp6AS7fgIIxTxXi",
  render_errors: [view: ExBinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExBin.PubSub, adapter: Phoenix.PubSub.PG2],
  # 5 MB
  max_byte_size: String.to_integer(System.get_env("MAX_BYTES") || "1048576")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
