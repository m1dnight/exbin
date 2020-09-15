defmodule ExBinWeb.SyncChannel do
  use ExBinWeb, :channel

  def join("sync:" <> syncid, _params, socket) do
    {:ok, assign(socket, :sync_id, 123)}
  end
end
