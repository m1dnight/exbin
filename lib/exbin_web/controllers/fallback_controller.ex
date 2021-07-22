defmodule ExBinWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ExBinWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ExBinWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    IO.inspect("call, #{inspect {:error, :not_found}}", label: "call")

    conn
    |> put_status(:not_found)
    |> put_view(ExBinWeb.ErrorView)
    |> render(:"404")
  end
end
