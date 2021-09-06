defmodule ExbinWeb.APIView do
  use ExbinWeb, :view
  alias ExbinWeb.APIView

  #############################################################################
  # API Views

  def render("show.json", %{snippet: snippet}) do
    render_one(snippet, APIView, "snippet.json")
  end

  def render("snippet.json", %{api: snippet}) do
    url = ExbinWeb.Router.Helpers.snippet_url(ExbinWeb.Endpoint, :view, snippet.name)
    %{content: snippet.content, name: snippet.name, created: snippet.inserted_at, url: url}
  end
end
