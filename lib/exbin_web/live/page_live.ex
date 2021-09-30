defmodule ExbinWeb.PageLive do
  use ExbinWeb, :live_view
  require Logger

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    socket = assign(socket, :token, token)
    {:ok, assign(socket, query: "", snippets: [])}
  end

  @impl true
  def mount(_params, _assigns, socket) do
    {:ok, assign(socket, query: "", snippets: [])}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    snippets =
      case Map.get(socket.assigns, :token) do
        nil ->
          Exbin.Snippets.search(query)

        t ->
          user = Exbin.Accounts.get_user_by_session_token(t)
          Exbin.Snippets.search(query, user.id)
      end

    Logger.debug("#{Enum.count(snippets)} results for query `#{query}`")
    {:noreply, assign(socket, snippets: snippets, query: query)}
  end
end
