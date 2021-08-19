defmodule ExBinWeb.Plug.FileNotFound do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "File Not Found")
    |> halt
  end
end
