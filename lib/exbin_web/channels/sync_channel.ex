defmodule ExBinWeb.SyncChannel do
  use ExBinWeb, :channel

  def join("sync:" <> syncid, _params, socket) do
    {:ok, assign(socket, :pad_id, syncid)}
  end

  def handle_in("change", params, socket) do
    IO.puts IO.ANSI.red() <> "Propagating change" <> IO.ANSI.reset()
    broadcast_from! socket, "change", params
    {:reply, :ok, socket}
  end
end
