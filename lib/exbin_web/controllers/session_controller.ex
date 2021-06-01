defmodule ExBinWeb.SessionController do
  use ExBinWeb, :controller
  require Logger

  def new(conn, _) do
    render(conn, "admin.html")
  end

  def create(conn, %{"session" => %{"password" => password}}) do
    case ExBin.Accounts.authenticate_admin(password) do
      {:ok, admin} ->
        conn
        |> ExBinWeb.Auth.login(admin)
        |> redirect(to: "/")

      {:error, _} ->
        conn
        |> redirect(to: "/list")
    end
  end

  def delete(conn, _) do
    IO.puts("Logging out!")

    conn
    |> ExBinWeb.Auth.logout()
    |> redirect(to: "/")
  end
end
