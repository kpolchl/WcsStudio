defmodule WcsStudioWeb.UserForgotPasswordLive do
  use WcsStudioWeb, :live_view

  alias WcsStudio.Accounts

  def render(assigns) do
    ~H"""
    <div class="px-4 py-4">
      <div class="mx-auto max-w-sm">
        <.header class="text-center">
          Forgot your password?
          <:subtitle>We'll send a password reset link to your inbox</:subtitle>
        </.header>

        <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
          <.input field={@form[:email]} type="email" placeholder="Email" required />
          <:actions>
            <.button phx-disable-with="Sending..." class="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-medium py-3 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-pink-500/25 hover:-translate-y-0.5">
              Send password reset instructions
            </.button>
          </:actions>
        </.simple_form>
        <p class="text-center text-sm mt-4">
          <.link href={~p"/users/register"} class="text-pink-400 hover:text-pink-300 hover:underline transition-colors duration-300 font-medium">Register</.link>
          | <.link href={~p"/users/log_in"} class="text-pink-400 hover:text-pink-300 hover:underline transition-colors duration-300 font-medium">Log in</.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
