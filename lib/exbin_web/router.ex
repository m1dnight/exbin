defmodule ExBinWeb.Router do
  use ExBinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExBinWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :new
    get "/new", PageController, :new
    post "/new", PageController, :create
    get "/:id", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExBinWeb do
  #   pipe_through :api
  # end
end
