defmodule ExBin.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExBin.Repo,
      # Start the endpoint when the application starts
      ExBinWeb.Endpoint,
      # Start the netcat endpoint
      ExBin.Netcat,
      # The cache for synced pads.
      ExBin.PadCache
    ]

    opts = [strategy: :one_for_one, name: ExBin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExBinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
