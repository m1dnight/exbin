defmodule ExbinWeb.PageController do
  use ExbinWeb, :controller

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, form: %{"text" => ""})
  end

  def create(conn, params) do
    IO.inspect(params, label: "params")
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, form: params)
  end
end
