defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller

  def about(conn, _params) do
    conn
    |> render("about.html")
  end
end
