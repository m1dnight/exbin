defmodule ExbinWeb.Router do
  use ExbinWeb, :router

  import ExbinWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExbinWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ExbinWeb.ApiAuth, exclude: []
  end

  pipeline :custom_files do
    plug ExbinWeb.Plug.CustomLogo
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/files", ExbinWeb do
    pipe_through [:custom_files]
    match :*, "/*not_found", Plug.FileNotFound, []
  end

  scope "/api", ExbinWeb do
    pipe_through :api

    post "/new", APIController, :new
    get "/:name", APIController, :show
  end

  scope "/snippet", ExbinWeb do
    pipe_through :browser

    get "/new", SnippetController, :new
    post "/new", SnippetController, :create
    get "/list", SnippetController, :list
    get "/statistics", SnippetController, :statistics
  end

  scope "/", ExbinWeb do
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
  # scope "/api", ExbinWeb do
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
      live_dashboard "/dashboard", metrics: ExbinWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", ExbinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", ExbinWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    get "/users/snippets", SnippetController, :personal_list
  end

  scope "/", ExbinWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
