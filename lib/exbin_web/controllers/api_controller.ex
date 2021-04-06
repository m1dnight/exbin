defmodule ExBinWeb.APIController do
  use ExBinWeb, :controller
  require Logger

  @doc """
  Create a new snippet through the API.
  """
  def new(conn, %{"content" => content, "private" => priv}) do
    args = %{"content" => content, "private" => priv}
    {:ok, snippet} = ExBin.Domain.insert(args)
    url = ExBinWeb.Router.Helpers.page_url(ExBinWeb.Endpoint, :show, snippet.name)
    text(conn, url)
  end
end
