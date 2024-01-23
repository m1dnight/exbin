import Config
# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :exbin, ExbinWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/exbin_web/(live|views)/.*(ex)$",
      ~r"lib/exbin_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

################################################################################
# Configuration parameters

# * `default_view`: :code, :reader, or :raw.
# * `ephemeral_age`: The maximum age of a snippet in seconds before it is deleted.
# * `brand`: The brand of the ExBin instance. Defaults to "ExBin"
# * `custom_logo_path`: Path to the file image of your custom logo
# * `custom_logo_size`: Height of the custom logo.
# * `base_url`: The url at which ExBin will be served.
# * `timezone`: The timezone of the ExBin instance.
# * `api_key`: The api key you want to use. Generate a secure one.

# Netcat

# * `tcp_port`: Port to listen for connections
# * `tcp_host`: Host to bind to to listen for connections
# * `max_size`: Maximum size in bytes that can be sent using netcat

config :exbin,
  base_url: "https://exbin.call-cc.be",
  timezone: "Europe/Brussels",
  default_view: :code,
  ephemeral_age: 60,
  brand: "ExBin",
  custom_logo_path: "",
  custom_logo_size: 30,
  api_key: "AyPwtQANkGPNWStxZT+k4qkifBmraC5EdBrJ2h/AMYwYxJ7wJBu0QsFkueRpSmIO",
  tcp_port: 9999,
  tcp_host: {0, 0, 0, 0},
  max_size: 2048

################################################################################
# Database parameters

# * `username`: Username of the database
# * `password`: Password of the database
# * `database`: Name of the database
# * `hostname`: Hostname of the database

config :exbin, Exbin.Repo,
  username: "postgres",
  password: "postgres",
  database: "exbin_dev",
  hostname: "localhost"

################################################################################
# Secrets (used for encryption and stuff)
# Fill in two values that are randomly generated with `openssl rand 64 | openssl enc -A -base64`

config :exbin, ExbinWeb.Endpoint,
  secret_key_base: "Q21q8HqA9Rd24KY9ZwMfeuqlCleNQqUJFWA7RcUHF1B3C7Faeucv2mFbB+Vo6bawBCJMJceoSuNQKnYpREqQuA==",
  live_view: "rkEAU575y2/9LVi5hwkSICTWMcLYF5QKZzzFKsi1QtGoO71ooE2vht2uU3k+tkgDsQxWNLu8eXinFSCQUB3zoA=="

################################################################################
# HTTP server configuration

# * `host`: The host at which this instance will run
# * `port`: The port at which the instance will listen
# * `scheme`: Either http or https

config :exbin, ExbinWeb.Endpoint,
  url: [host: "exbin.call-cc.be", port: 4000, scheme: "http"],
  http: [
    port: 4000,
    transport_options: [socket_opts: [:inet6]]
  ]

################################################################################
# Configuration for logging

# * `level`: Level for debugging. `:debug` for debugging, `:warning` for production.

config :logger,
  level: :debug

################################################################################
# Configuration for mailing

# Most of the parameters are self-explanatory.
# If you have a TLS connection to the SMTP server, set `tls` to `true`, and `ssl` to `false`.

mailing = :local

if mailing == :local do
  config :exbin, Exbin.Mailer,
    adapter: Swoosh.Adapters.SMTP,
    relay: "smtp.com",
    username: "exbin",
    password: "exbin",
    from: "exbin@exbin.exbin",
    ssl: false,
    tls: true,
    auth: :always,
    port: 587,
    retries: 2
else
  config :exbin, Exbin.Mailer, adapter: Swoosh.Adapters.Local
  config :exbin, Exbin.Mailer, from: "exbin@example.com"
  config :swoosh, :api_client, false
end
