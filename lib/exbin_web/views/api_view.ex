defmodule ExBinWeb.APIView do
  use ExBinWeb, :view
  alias ExBinWeb.APIView

  #############################################################################
  # API Views

  def render("show.json", %{snippet: snippet}) do
    render_one(snippet, APIView, "snippet.json")
  end

  def render("snippet.json", %{api: snippet}) do
    url = ExBinWeb.Router.Helpers.snippet_url(ExBinWeb.Endpoint, :view, snippet.name)
    %{content: snippet.content, name: snippet.name, created: snippet.inserted_at, url: url}
  end
end
