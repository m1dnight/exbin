defmodule ExBinWeb.APIController do
  use ExBinWeb, :controller

  action_fallback ExBinWeb.FallbackController

  def show(conn, %{"name" => name}) do
    with {:ok, snippet} <- ExBin.Snippets.get_by_name(name) do
      render(conn, "show.json", snippet: snippet)
    end
  end
end
