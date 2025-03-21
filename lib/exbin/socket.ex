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
          {:ok, %{listener: listen_socket}}

        {:error, reason} ->
          {:stop, reason}
      end

    GenServer.cast(self(), :accept)
    return_value
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_cast(:accept, %{listener: s} = state) do
    # Accept on the socket for the next connection.
    {:ok, client} = :gen_tcp.accept(s)

    # Register the client, and ensure it's not spamming.
    {:ok, {client_ip, _port}} = :inet.peername(client)

    case Hammer.check_rate("#{inspect(client_ip)}", 60_000 * 60 * 2, 2) do
      {:allow, _count} ->
        Task.async(fn -> serve(client) end)
        GenServer.cast(self(), :accept)
        {:noreply, state}

      {:deny, _limit} ->
        :gen_tcp.send(client, "You are rated limited. Try again later.")
        :gen_tcp.close(client)
        GenServer.cast(self(), :accept)
        {:noreply, state}
    end
  end

  defp serve(client_socket) do
    Logger.debug("Serving #{inspect(:inet.peername(client_socket))}")
    limit = Application.get_env(:exbin, :max_size)
    data = do_rcv(client_socket, <<>>, limit)

    case data do
      nil ->
        :gen_tcp.send(client_socket, "File larger than #{limit} bytes.\n")

      data ->
        Logger.debug("Received #{byte_size(data)} bytes.")

        reply =
          if is_http_request?(data) do
            reply_to_http(data)
          else
            {:ok, snippet} = Exbin.Snippets.insert(%{"content" => data, "private" => "true"})
            "#{Application.get_env(:exbin, :base_url)}/r/#{snippet.name}\n"
          end

        :gen_tcp.send(client_socket, reply)
    end

    :gen_tcp.close(client_socket)
  end

  defp do_rcv(_socket, _bytes, count) when count <= 0 do
    nil
  end

  defp do_rcv(socket, bytes, count) do
    case :gen_tcp.recv(socket, 0, 1000) do
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

  defp is_http_request?(data) do
    Regex.match?(~r/GET|POST|PUT|DELETE|PATCH|OPTIONS|HEAD|TRACE|CONNECT/, data)
  end

  defp reply_to_http(_request) do
    bomb = Application.app_dir(:exbin, "/priv/10G.gzip")
    filesize = File.stat!(bomb)

    """
    HTTP/1.1 200 OK\r
    Content-Type: text/html; charset=UTF-8\r
    Content-Length: #{filesize.size}\r
    Content-Encoding: gzip\r
    \r
    """ <> File.read!(bomb)
  end
end
