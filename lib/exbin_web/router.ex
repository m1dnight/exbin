defmodule ExBinWeb.Router do
  use ExBinWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(ExBinWeb.Auth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug ExBinWeb.Token, exclude: []
  end

  scope "/api", ExBinWeb do
    pipe_through(:api)

    post("/snippet", APIController, :new)
  end

  scope "/", ExBinWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    delete("/login", SessionController, :delete)

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
    get("/code/:name", PageController, :code)
    get("/:name", PageController, :show)
    delete("/:name", PageController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExBinWeb do
  #   pipe_through :api
  # end
end
