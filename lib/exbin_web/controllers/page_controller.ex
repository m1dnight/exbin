defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller
  require Logger

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  @doc """
  The new snippet page. Where the user can enter code.
  """
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @doc """
  Static page with about exbin content.
  """
  def about(conn, _params) do
    render(conn, "about.html")
  end

  @doc """
  Shows a list of all the public snippets, ordered from new to old.
  """
  def list(conn, _params) do
    snippets = ExBin.Domain.list_public_snippets()
    render(conn, "list.html", snippets: snippets)
  end

  @doc """
  Shows a few statistics about exbin. E.g., pastes/hour and stuff like that.
  """
  def stats(conn, _params) do
    stats =
      ConCache.get_or_store(:stats_cache, :summary, fn ->
        public_count = ExBin.Domain.count_public_snippets()
        private_count = ExBin.Domain.count_private_snippets()
        stats = ExBin.Domain.Statistics.stats_activity()
        avg_length = ExBin.Domain.Statistics.average_length()
        avg_views = ExBin.Domain.Statistics.compute_average_views()
        total = ExBin.Domain.Statistics.count_snippets()
        most_popular = ExBin.Domain.Statistics.most_popular()

        %{
          avg_views: avg_views,
          public_count: public_count,
          private_count: private_count,
          counts: stats,
          avg_length: avg_length,
          total: total,
          most_popular: most_popular
        }
      end)

    render(conn, "stats.html", stats: stats)
  end

  @doc """
  POST end of creating a paste.
  """
  def create(conn, _args = %{"snippet" => args}) do
    {:ok, snippet} = ExBin.Domain.insert(args)
    redirect(conn, to: "/#{snippet.name}")
  end

  @doc """
  POST search query for public snippets.
  """
  def search(conn, _args = %{"query" => %{"content" => query}}) do
    res = ExBin.Domain.search(query)
    Logger.debug("#{Enum.count(res)} results for query `#{query}`")
    render(conn, "list.html", snippets: res)
  end

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  @doc """
  Shows a paste to the user. Every hit increments the viewcount of each paste as well.
  """
  def show(conn, %{"name" => name}) do
    case Application.get_env(:exbin, :default_view) do
      "code" ->
        redirect(conn, to: "/code/#{name}")

      "reader" ->
        redirect(conn, to: "/reader/#{name}")

      "raw" ->
        redirect(conn, to: "/raw/#{name}")

      other ->
        Logger.warn("#{other} is not a valid default view. Defaulting to code view.")
        redirect(conn, to: "/code/#{name}")
    end
  end

  @doc """
  Shows a paste to the user in code view. Every hit increments the viewcount of each paste as well.
  """
  def code(conn, %{"name" => name}) do
    case ExBin.Domain.get_by_name(name) do
      nil ->
        conn
        |> put_view(ExBinWeb.ErrorView)
        |> render("404.html")

      snippet ->
        {:ok, snippet} = ExBin.Domain.update_viewcount(snippet)
        render(conn, "show.html", snippet: snippet)
    end
  end

  @doc """
  Shows a paste to the user in reader view. Every hit increments the viewcount of each paste as well.
  """
  def reader(conn, %{"name" => name}) do
    case ExBin.Domain.get_by_name(name) do
      nil ->
        conn
        |> put_view(ExBinWeb.ErrorView)
        |> render("404.html")

      snippet ->
        {:ok, snippet} = ExBin.Domain.update_viewcount(snippet)
        render(conn, "reader.html", snippet: snippet)
    end
  end

  @doc """
  Shows the raw version of a snippet, no markup no nothing.
  """
  def raw(conn, %{"name" => name}) do
    case ExBin.Domain.get_by_name(name) do
      nil ->
        conn
        |> put_view(ExBinWeb.ErrorView)
        |> render("404.html")

      snippet ->
        {:ok, snippet} = ExBin.Domain.update_viewcount(snippet)
        text(conn, snippet.content)
    end
  end
end
