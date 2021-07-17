defmodule ExBin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  import Supervisor.Spec
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExBin.Repo,
      # Start the Telemetry supervisor
      ExBinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExBin.PubSub},
      # Start the Endpoint (http/https)
      ExBinWeb.Endpoint,
      # Start a worker by calling: ExBin.
      ExBin.Scrubber,
      # Start the socket server.
      ExBin.Netcat
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExBinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
