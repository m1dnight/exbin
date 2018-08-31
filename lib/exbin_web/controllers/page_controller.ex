defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
