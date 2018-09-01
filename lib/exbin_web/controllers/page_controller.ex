defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, _args = %{"snippet" => %{"snippet_content" => content}}) do
    render conn, "index.html"
  end
end
