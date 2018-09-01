defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, args = %{"snippet" => %{"snippet_content" => content}}) do
    IO.puts """
    #{inspect content}
    """
    render conn, "index.html"
  end
end
