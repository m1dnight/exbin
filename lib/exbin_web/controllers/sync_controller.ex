defmodule ExBinWeb.SyncController do
  use ExBinWeb, :controller
  require Logger

  @doc """
  The new snippet page. Where the user can enter code.
  """
  def new(conn, _params) do
    render(conn, "new.html")
  end

end
