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
    this = self()

    unless String.trim(query) == "" do
      case Map.get(socket.assigns, :token) do
        nil ->
          Exbin.Snippets.search_stream(query, fn results ->
            send(this, {:query_result, results})
          end)

        t ->
          user = Exbin.Accounts.get_user_by_session_token(t)

          Exbin.Snippets.search_stream(query, user.id, fn results ->
            send(this, {:query_result, results})
          end)
      end
    end

    {:noreply, assign(socket, query: query, snippets: [])}
  end

  @impl true
  def handle_info({:query_result, snippets}, socket) do
    current_results = Map.get(socket.assigns, :snippets, [])
    socket = assign(socket, snippets: current_results ++ snippets)
    {:noreply, socket}
  end
end
