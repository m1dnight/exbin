# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended.

import Config

#############################################################################
# General Configuration

default_view =
  case System.get_env("DEFAULT_VIEW") do
    "code" -> :code
    "reader" -> :reader
    "raw" -> :raw
    other -> raise "Invalid value for DEFAULT_VIEW: #{other}"
  end

ephemeral_age = String.to_integer(System.get_env("EPHEMERAL_AGE") || "60")
brand = if System.get_env("BRAND") == nil or System.get_env("BRAND") == "", do: "Exbin", else: System.get_env("BRAND")

config :exbin,
  default_view: default_view,
  ephemeral_age: ephemeral_age,
  brand: brand

#############################################################################
# Database

db_host = System.get_env("DATABASE_HOST") || raise "environment variable DATABASE_HOST is missing."
db_database = System.get_env("DATABASE_DB") || raise "Environment variable DATABASE_DB is missing"
db_username = System.get_env("DATABASE_USER") || raise "Environment variable DATABASE_USER is missing"
db_password = System.get_env("DATABASE_PASSWORD") || raise "Environment variable DATABASE_PASSWORD is missing"
database_url = "ecto://#{db_username}:#{db_password}@#{db_host}/#{db_database}"

config :exbin, Exbin.Repo,
  # ssl: true,
  url: database_url,
  database: db_database,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

#############################################################################
# Secrets

secret_key_base = System.get_env("SECRET_KEY_BASE") || raise "environment variable SECRET_KEY_BASE is missing."

config :exbin, ExbinWeb.Endpoint, secret_key_base: secret_key_base

signing_salt = System.get_env("SECRET_SALT") || raise "environment variable SECRET_SALT is missing."

config :exbin, ExbinWeb.Endpoint, live_view: [signing_salt: signing_salt]
#############################################################################
# TCP Endpoint

tcp_port = String.to_integer(System.get_env("TCP_PORT")) || raise "environment variable TCP_PORT is missing."

tcp_host =
  System.get_env("TCP_HOST") |> to_charlist() |> :inet.parse_address() |> elem(1) ||
    raise "environment variable TCP_HOST is missing."

max_size = String.to_integer(System.get_env("MAX_SIZE")) || raise "environment variable MAX_SIZE is missing."

config :exbin,
  tcp_port: tcp_port,
  tcp_host: tcp_host,
  max_size: max_size

#############################################################################
# Base URL

base_url = System.get_env("BASE_URL") || raise "environment variable BASE_URL is missing."

config :exbin,
  base_url: base_url

#############################################################################
# Timezone

timezone = System.get_env("TZ") || raise "environment variable TZ is missing."

config :exbin,
  timezone: timezone

#############################################################################
# HTTP Endpoint

host = System.get_env("HOST") || raise "environment variable HOST is missing."

{scheme, port} =
  if System.get_env("HTTPS") == "true" do
    {"https", 443}
  else
    {"http", 80}
  end

scheme =
  config :exbin, ExbinWeb.Endpoint,
    url: [host: host, port: port, scheme: scheme],
    http: [
      port: String.to_integer(System.get_env("HTTP_PORT") || "1234"),
      transport_options: [socket_opts: [:inet6]]
    ]

config :exbin, ExbinWeb.Endpoint, server: true

#############################################################################
# API Security

apikey = System.get_env("API_KEY") || nil

config :exbin,
  apikey: apikey

#############################################################################
# Custom Logo

config :exbin,
  custom_logo_path: System.get_env("CUSTOM_LOGO_PATH"),
  custom_logo_size: System.get_env("CUSTOM_LOGO_SIZE") || "30"

#############################################################################
# Emails

config :exbin, Exbin.Mailer, adapter: Swoosh.Adapters.SMTP

smtprelay = System.get_env("SMTP_RELAY") || raise "environment variable SMTP_RELAY is missing."
smtpuser = System.get_env("SMTP_USER") || raise "environment variable SMTP_USER is missing."
smtppassword = System.get_env("SMTP_PASSWORD") || raise "environment variable SMTP_PASSWORD is missing."
smtpfrom = System.get_env("SMTP_FROM") || raise "environment variable SMTP_FROM is missing."
smtpport = System.get_env("SMTP_PORT") || raise "environment variable SMTP_PORT is missing."

config :exbin, Exbin.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: smtprelay,
  username: smtpuser,
  password: smtppassword,
  from: smtpfrom,
  ssl: true,
  auth: :always,
  auth: :always,
  port: smtpport,
  retries: 2
