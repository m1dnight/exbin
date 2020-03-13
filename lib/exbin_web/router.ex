defmodule ExBinWeb.Router do
  use ExBinWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ExBinWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :new)
    get("/list", PageController, :list)
    get("/new", PageController, :new)
    get("/about", PageController, :about)
    get("/stats", PageController, :stats)
    post("/new", PageController, :create)
    post("/search", PageController, :search)
    get("/raw/:name", PageController, :raw)
    get("/:name", PageController, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExBinWeb do
  #   pipe_through :api
  # end
end
