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
      ExBin.PadCache,
      # Cache for snippets
      Supervisor.child_spec(
        {ConCache,
         [
           name: :snippet_cache,
           ttl_check_interval: :timer.minutes(1),
           global_ttl: :timer.hours(2),
           touch_on_read: true
         ]},
        id: :snippet_cache
      ),
      # Cache for statistics
      Supervisor.child_spec(
        {ConCache,
         [
           name: :stats_cache,
           ttl_check_interval: :timer.minutes(1),
           global_ttl: :timer.minutes(10),
           touch_on_read: false
         ]},
        id: :stats_cache
      )
    ]

    opts = [strategy: :one_for_one, name: ExBin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExBinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
