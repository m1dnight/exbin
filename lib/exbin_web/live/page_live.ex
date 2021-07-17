defmodule ExBinWeb.PageLive do
  use ExBinWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug "Mount"
    {:ok, assign(socket, query: "", snippets: [])}
  end

  def handle_event("suggest", %{"q" => query}, socket) do
    IO.puts "Suggest #{query}"
    snippets = ExBin.Snippets.search(query)
    Logger.debug("#{Enum.count(snippets)} results for query `#{query}`")
    {:noreply, assign(socket, snippets: snippets, query: query)}
  end
end
