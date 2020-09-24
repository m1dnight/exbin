defmodule ExBinWeb.SyncController do
  use ExBinWeb, :controller
  require Logger

  @doc """
  The new snippet page. Where the user can enter code.
  """
  def new(conn, _params) do
    uuid = :crypto.strong_rand_bytes(32) |> Base.url_encode64 |> binary_part(0, 5) |> String.upcase()
    redirect(conn, to: "/sync/#{uuid}")
  end


  def show(conn, %{"id" => name}) do
    render(conn, "pad.html", uuid: name, text: "snippet id: #{inspect name} type here")
  end

end
