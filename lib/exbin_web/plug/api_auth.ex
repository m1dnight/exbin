defmodule ExbinWeb.ApiAuth do
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
          ~s({"error": "invalid token"})
        )
        |> halt()
      end
    end
  end

  # Checks if the passed token matches the one in the config.
  defp valid_token?(token) do
    global_token = Application.get_env(:exbin, :apikey)

    case {global_token, token} do
      # No token means no auth!
      {nil, _} ->
        true

      {expected, given} ->
        expected == given
    end
  end
end
