defmodule ExBinWeb.SyncChannel do
  use ExBinWeb, :channel

  def join("sync:" <> syncid, _params, socket) do
    send(self, :on_join)
    {:ok, assign(socket, :pad_id, syncid)}
  end

  def handle_in("change", params, socket) do
    IO.puts(IO.ANSI.red() <> "Propagating change" <> IO.ANSI.reset())
    broadcast_from!(socket, "change", params)
    {:reply, :ok, socket}
  end

  def handle_in("state", params, socket) do
    IO.inspect(socket.assigns.pad_id)
    IO.inspect(params, pretty: true)
    ExBin.PadCache.store(socket.assigns.pad_id, params)
    {:reply, :ok, socket}
  end

  def handle_info(:on_join, socket) do
    case ExBin.PadCache.fetch(socket.assigns.pad_id) do
      nil ->
        {:noreply, socket}

      str ->
        push(socket, "init", %{:state => str})
        {:noreply, socket}
    end
  end
end
