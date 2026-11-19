defmodule WcsStudioWeb.UserLoginLive do
  use WcsStudioWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-4">
      <div class="mx-auto max-w-sm ">
        <.header class="text-center">
          {gettext("Log in to account")}
          <:subtitle>
            {gettext("Don't have an account?")}
            <.link
              navigate={~p"/users/register"}
              class="font-semibold text-pink-400 hover:text-pink-300 hover:underline transition-colors duration-300"
            >
              {gettext("Sign up")}
            </.link>
            {gettext("for an account now.")}
          </:subtitle>
        </.header>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label={gettext("Email")} required />
          <.input field={@form[:password]} type="password" label={gettext("Password")} required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label={gettext("Keep me logged in")} />
            <.link
              href={~p"/users/reset_password"}
              class="font-semibold text-pink-400 hover:text-pink-300 hover:underline transition-colors duration-300"
            >
              {gettext("Forgot your password ?")}
            </.link>
          </:actions>
          <:actions>
            <.btn type="submit" phx-disable-with="Logging in..." class="w-full">
              {gettext("Log in")} <span aria-hidden="true">→</span>
            </.btn>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
