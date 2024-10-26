defmodule Exbin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExbinWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:exbin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Exbin.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Exbin.Finch},
      # Start a worker by calling: Exbin.Worker.start_link(arg)
      # {Exbin.Worker, arg},
      # Start to serve requests, typically the last entry
      ExbinWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exbin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExbinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
