defmodule ExBinWeb.Plug.ViewCounter do
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    # The snippet name and identifier for client.
    %{"name" => name} = conn.path_params
    client = identifier(conn)
    view_interval = opts[:view_interval]

    Logger.debug("#{client} is viewing snippet #{name} (#{view_interval})")

    case ExRated.check_rate({name, client}, view_interval, 1) do
      {:ok, _} ->
        update_viewcount(name)

      {:error, _} ->
        :ok
    end

    conn
  end

  defp update_viewcount(name) do
    case ExBin.Snippets.get_by_name(name) do
      {:error, :not_found} ->
        {:error, "snippet not found"}

      {:ok, snippet} ->
        ExBin.Snippets.update_viewcount(snippet)
    end
  end

  defp identifier(conn) do
    path = Enum.join(conn.path_info, "/")
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    cookie = conn.req_cookies["_exbin_key"]
    id = "#{ip}:#{path}:#{cookie}"
    :crypto.hash(:md5, id) |> Base.encode16()
  end
end
