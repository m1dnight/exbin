defmodule ExbinWeb.Plug.CustomLogo do
  @moduledoc """
  Allows defining a path via Application configuration that will be served from
  the filesystem.
  """
  alias Plug.Conn

  def init(opts), do: opts

  def call(%Conn{request_path: "/files/" <> requested_filename} = conn, _opts) do
    with {:ok, dirname, basename} <- custom_logo_paths_tuple(),
         true <- String.equivalent?(requested_filename, basename) do
      Plug.run(conn, [{Plug.Static, [at: "/files", from: dirname, only: [basename]]}])
    else
      _ -> conn
    end
  end

  # Note that the shortest possible path is "/d/f". This may potentially be
  # incorrect if running on different platforms, or maybe in specific relative
  # path scenarios, however we will issue an injunction to the user to use only
  # absolute paths anyway, so this should be fine...
  defp custom_logo_paths_tuple() do
    case Application.get_env(:exbin, :custom_logo_path) do
      path when is_bitstring(path) and byte_size(path) > 4 -> {:ok, Path.dirname(path), Path.basename(path)}
      _ -> nil
    end
  end
end
