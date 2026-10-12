defmodule WcsStudio.Integration.AuthFlowTest do
  @moduledoc """
  End-to-end authentication journey exercised through the real router, session
  plug pipeline and LiveView layers.
  """
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures

  test "a visitor can register, browse, log out and log back in", %{conn: conn} do
    # Anonymous visitor reaches the landing page.
    conn = get(conn, ~p"/")
    assert html_response(conn, 200)
    refute get_session(conn, :user_token)

    # Registers through the LiveView form.
    {:ok, lv, _html} = live(conn, ~p"/users/register")
    email = unique_user_email()

    form =
      form(lv, "#registration_form",
        user: %{email: email, username: "flowtester", password: valid_user_password()}
      )

    render_submit(form)
    conn = follow_trigger_action(form, conn)

    assert redirected_to(conn) == ~p"/"
    assert get_session(conn, :user_token)

    # The session now renders as authenticated on a regular request.
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ email

    # ...and on a LiveView authenticated route.
    {:ok, _lv, html} = live(conn, ~p"/user_profile")
    assert html =~ "flowtester"

    # Logs out.
    conn = delete(conn, ~p"/users/log_out")
    assert redirected_to(conn) == ~p"/"
    refute get_session(conn, :user_token)

    # A protected LiveView redirects anonymous visitors to the login page.
    assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/users/settings")
    assert path == "/users/log_in"

    # Logs back in with the credentials chosen during registration.
    conn =
      post(conn, ~p"/users/log_in", %{
        "user" => %{"email" => email, "password" => valid_user_password()}
      })

    assert redirected_to(conn) == ~p"/"
    assert get_session(conn, :user_token)

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ email
  end

  test "invalid credentials keep the visitor logged out", %{conn: conn} do
    conn =
      post(conn, ~p"/users/log_in", %{
        "user" => %{"email" => "nobody@example.com", "password" => "wrong password"}
      })

    assert redirected_to(conn) == ~p"/users/log_in"
    refute get_session(conn, :user_token)
    assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
  end
end
