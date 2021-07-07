defmodule ExBinWeb.Token do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:exclude] do
      conn
    else
      token = Map.get(conn.body_params, "token", nil)

      if valid_token?(token) do
        conn
      else
        conn
        |> send_resp(
          500,
          "JSON API requires a token defined as \"token\" in the JSON payload. Either your token is invalid, or it is missing."
        )
        |> halt()
      end
    end
  end

  # Checks if the passed token matches the one in the config.
  defp valid_token?(token) do
    global_token = Application.get_env(:exbin, ExBinWeb.Endpoint)[:api_token]

    IO.inspect global_token, label: "global token"
    case {global_token, token} do
      {nil, _} ->
        true

      {expected, given} ->
        expected == given
    end
  end
end
