defmodule WcsStudioWeb.Router do
  use WcsStudioWeb, :router
  import Plug.Conn

  import WcsStudioWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WcsStudioWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :set_locale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_auth do
    plug :require_authenticated_user
    plug :require_admin
  end

  defp set_locale(conn, _opts) do
    locale = get_session(conn, :locale) || "en"
    Gettext.put_locale(WcsStudioWeb.Gettext, locale)

    conn
    |> assign(:locale, locale)
    |> put_session(:locale, locale)
  end

  scope "/", WcsStudioWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/locale/:locale", LocaleController, :set_locale
  end

  # Other scopes may use custom stacks.
  # scope "/api", WcsStudioWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:wcs_studio, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WcsStudioWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", WcsStudioWeb do
    pipe_through [:browser, :admin_auth]

    # FIX: Use ensure_authenticated instead of mount_current_user
    live_session :admin_auth,
                 on_mount: [
                   {WcsStudioWeb.UserAuth, :ensure_authenticated},
                   {WcsStudioWeb.UserAuth, :set_locale}
                 ] do
      live "/dashboard", AdminDashboardLive
      live "/lessons", LessonsLive
    end
  end

  defp require_admin(conn, _opts) do
    WcsStudioWeb.UserAuth.require_role(conn, "admin")
  end

  scope "/", WcsStudioWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
                 on_mount: [
                   {WcsStudioWeb.UserAuth, :redirect_if_user_is_authenticated},
                   {WcsStudioWeb.UserAuth, :set_locale}
                 ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", WcsStudioWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
                 on_mount: [
                   {WcsStudioWeb.UserAuth, :ensure_authenticated},
                   {WcsStudioWeb.UserAuth, :set_locale}
                 ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", WcsStudioWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
                 on_mount: [
                   {WcsStudioWeb.UserAuth, :mount_current_user},
                   {WcsStudioWeb.UserAuth, :set_locale}
                 ] do
      live "/patterns", PatternsLive
      live "/dance_types", DanceTypesLive
      live "/blog", BlogLive, :index
      live "/blog/:id", BlogPostLive, :show
      live "/connect", ConnectLive
      live "/user_profile", UserProfile
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end