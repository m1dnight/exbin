defmodule ExBinWeb.Router do
  use ExBinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExBinWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExBinWeb do
    pipe_through :api

    get "/:name", APIController, :show
  end

  scope "/snippet", ExBinWeb do
    pipe_through :browser

    get "/new", SnippetController, :new
    post "/new", SnippetController, :create
    get "/list", SnippetController, :list
    get "/statistics", SnippetController, :statistics
  end

  scope "/", ExBinWeb do
    pipe_through :browser

    # Static Pages
    get "/about", PageController, :about

    live "/search", PageLive, :index
    # Snippets.
    get "/", SnippetController, :new
    get "/b/:name", SnippetController, :readerview
    get "/c/:name", SnippetController, :codeview
    get "/r/:name", SnippetController, :rawview
    get "/:name", SnippetController, :view
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExBinWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ExBinWeb.Telemetry
    end
  end
end
