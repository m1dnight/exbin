defmodule ExbinWeb.SnippetController do
  use ExbinWeb, :controller

  # Only increment viewcounter every 24 hours.
  plug ExbinWeb.Plug.ViewCounter, [view_interval: 86_400_000] when action in [:view, :readerview, :codeview, :rawview]

  @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"snippet" => args}) do
    if args["content"] == "" or String.trim(args["content"]) == "" do
      conn
      |> put_flash(:error, "💩 Empty snippets not allowed.")
      |> redirect(to: "/")
    else
      {:ok, snippet} = Exbin.Snippets.insert(args)
      redirect(conn, to: "/#{snippet.name}")
    end
  end

  def view(conn, %{"name" => name}) do
    render_snippet(conn, name, Application.get_env(:exbin, :default_view))
  end

  def codeview(conn, %{"name" => name}) do
    render_snippet(conn, name, :code)
  end

  def readerview(conn, %{"name" => name}) do
    render_snippet(conn, name, :reader)
  end

  def rawview(conn, %{"name" => name}) do
    render_snippet(conn, name, :raw)
  end

  def render_snippet(conn, name, view) do
    case Exbin.Snippets.get_by_name(name) do
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "💩 Snippet not found.")
        |> redirect(to: "/")

      {:ok, snippet} ->
        case view do
          :code ->
            render(conn, "code.html", snippet: snippet)

          :raw ->
            text(conn, snippet.content)

          :reader ->
            render(conn, "reader.html", snippet: snippet)

          _ ->
            conn
            |> put_flash(:error, "💩 An error occured showing this snippet.")
            |> redirect(to: "/")
        end
    end
  end

  def list(conn, _params) do
    case Exbin.Snippets.list_public_snippets() do
      [] ->
        conn
        |> put_flash(:error, "😢 There are no public snippets to show!")
        |> render("list.html", snippets: [])

      snippets ->
        render(conn, "list.html", snippets: snippets)
    end
  end

  def delete(conn, _params) do
    render(conn, "index.html")
  end

  def statistics(conn, _params) do
    data = %{
      monthly: Exbin.Stats.count_per_month(),
      avg_views: Exbin.Stats.average_viewcount(),
      avg_length: Exbin.Stats.average_length(),
      privpub: Exbin.Stats.count_public_private(),
      most_viewed: Exbin.Stats.most_popular()
    }

    render(conn, "statistics.html", data: data)
  end
end
