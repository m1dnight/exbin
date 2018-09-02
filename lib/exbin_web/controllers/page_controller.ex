defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller
  alias ExBin.{Snippet, Repo}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _args = %{"snippet" => args}) do
    IO.inspect(args)
    changeset = Snippet.changeset(%Snippet{}, args)

    IO.inspect(changeset)
    {:ok, snippet} = Repo.insert(changeset)

    redirect(conn, to: "/#{snippet.id}")
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Snippet, id) do
      nil ->
        IO.puts "Rendering 404!"
        conn
        |>put_view(ExBinWeb.ErrorView)
        |> render("404.html")

      snippet ->
        render(conn, "show.html", snippet: snippet)
    end
  end
end
