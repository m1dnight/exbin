defmodule ExBin.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      # Start the Ecto repository
      supervisor(ExBin.Repo, []),
      # Start the endpoint when the application starts
      supervisor(ExBinWeb.Endpoint, []),
      # Start the netcat endpoint
      worker(ExBin.Netcat, [])
    ]

    opts = [strategy: :one_for_one, name: ExBin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExBinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
