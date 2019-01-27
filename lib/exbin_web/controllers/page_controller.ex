defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def list(conn, _params) do
    snippets = ExBin.Domain.list_public_snippets()
    render(conn, "list.html", snippets: snippets)
  end

  def stats(conn, _params) do
    public_count = ExBin.Domain.count_public_snippets()
    private_count = ExBin.Domain.count_private_snippets()
    stats = ExBin.Domain.Statistics.stats_activity()
    render(conn, "stats.html", stats: %{public_count: public_count, private_count: private_count, counts: stats})
  end

  def create(conn, _args = %{"snippet" => args}) do
    IO.inspect(args)
    {:ok, snippet} = ExBin.Domain.insert(args)
    redirect(conn, to: "/#{snippet.name}")
  end

  def show(conn, %{"name" => name}) do
    case Repo.one(from(s in Snippet, where: s.name == ^name)) do
      nil ->
        conn
        |> put_view(ExBinWeb.ErrorView)
        |> render("404.html")

      snippet ->
        {:ok, snippet} = ExBin.Domain.update_viewcount(snippet)
        render(conn, "show.html", snippet: snippet)
    end
  end

  def raw(conn, %{"name" => name}) do
    case Repo.one(from(s in Snippet, where: s.name == ^name)) do
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
