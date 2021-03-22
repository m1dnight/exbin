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

  scope "/api", ExBinWeb do
    pipe_through(:api)

    post("/snippet", PageController, :new_from_api)
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
    get("/sync", SyncController, :new)
    get("/sync/:id", SyncController, :show)
    get("/raw/:name", PageController, :raw)
    get("/reader/:name", PageController, :reader)
    get("/:name", PageController, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExBinWeb do
  #   pipe_through :api
  # end
end
