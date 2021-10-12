defmodule Exbin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  import Supervisor.Spec
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Exbin.Repo,
      # Start the Telemetry supervisor
      ExbinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Exbin.PubSub},
      # Start the Endpoint (http/https)
      ExbinWeb.Endpoint,
      # Start a worker by calling: Exbin.
      Exbin.Scrubber,
      # Start the socket server.
      Exbin.Netcat,
      # STatistics Cache
      {Cachex, name: :stats_cache}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exbin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExbinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
