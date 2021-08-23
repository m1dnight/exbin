defmodule ExBinWeb.PageController do
  use ExBinWeb, :controller

  def about(conn, _params) do
    conn
    |> render("about.html")
  end

  def static_file_not_found(conn, _params) do
    conn
    |> put_status(404)
    |> text("File Not Found")
  end
end
