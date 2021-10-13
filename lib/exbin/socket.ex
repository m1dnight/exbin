defmodule Exbin.Netcat do
  use GenServer
  require Logger

  def start_link(_args) do
    port = Application.get_env(:exbin, :tcp_port)
    ip = Application.get_env(:exbin, :tcp_host)
    Logger.info("TCP Server listening on #{inspect(ip)}:#{inspect(port)}")
    GenServer.start_link(__MODULE__, [ip, port], name: __MODULE__)
  end

  def init([ip, port]) do
    opts = [:binary, packet: :raw, active: false, reuseaddr: true, ip: ip, exit_on_close: false]

    return_value =
      case :gen_tcp.listen(port, opts) do
        {:ok, listen_socket} ->
          {:ok, %{listener: listen_socket, history: %{}}}

        {:error, reason} ->
          {:stop, reason}
      end

    GenServer.cast(self(), :accept)
    return_value
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_cast(:accept, %{listener: s, history: h} = state) do
    # Accept on the socket for the next connection.
    {:ok, client} = :gen_tcp.accept(s)

    # Register the client, and ensure it's not spamming.
    {:ok, {client_ip, _port}} = :inet.peername(client)

    # Check when the client was last seen.
    last_seen = Map.get(h, client_ip, DateTime.from_gregorian_seconds(0))

    if DateTime.diff(DateTime.utc_now(), last_seen) > 10 do
      Task.async(fn -> serve(client) end)
      state = %{listener: s, history: Map.put(h, client_ip, DateTime.utc_now())}
      GenServer.cast(self(), :accept)
      {:noreply, state}
    else
      :gen_tcp.send(client, "You are rated limited. Try again later.")
      :gen_tcp.close(client)
      GenServer.cast(self(), :accept)
      {:noreply, state}
    end
  end

  defp serve(client_socket) do
    Logger.debug("Serving #{inspect :inet.peername(client_socket)}")
    limit = Application.get_env(:exbin, :max_size)
    data = do_rcv(client_socket, <<>>, limit)

    case data do
      nil ->
        :gen_tcp.send(client_socket, "File larger than #{limit} bytes.\n")

      data ->
        Logger.debug("Received #{byte_size(data)} bytes.")
        {:ok, snippet} = Exbin.Snippets.insert(%{"content" => data, "private" => "true"})
        :gen_tcp.send(client_socket, "#{Application.get_env(:exbin, :base_url)}/r/#{snippet.name}\n")
    end

    :gen_tcp.close(client_socket)
  end

  defp do_rcv(_socket, _bytes, count) when count <= 0 do
    nil
  end

  defp do_rcv(socket, bytes, count) do
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, fresh_bytes} ->
        do_rcv(socket, bytes <> fresh_bytes, count - byte_size(fresh_bytes))

      {:error, :closed} ->
        IO.puts("Socket closed at the client side.")
        bytes

      {:error, e} ->
        IO.puts("An error while receiving bytes: #{inspect(e)}")
        bytes
    end
  end
end
