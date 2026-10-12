defmodule WcsStudioWeb.UserProfileTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.PatternsFixtures
  import WcsStudio.UserPatternsFixtures

  setup %{conn: conn} do
    user = user_fixture(username: "dancer")

    %{conn: conn |> log_in_user(user) |> put_session(:locale, "en"), user: user}
  end

  test "renders the profile of the logged in user", %{conn: conn, user: user} do
    {:ok, _live, html} = live(conn, ~p"/user_profile")

    assert html =~ "dancer"
    assert html =~ user.email
    assert html =~ "Attended Lessons"
    assert html =~ "Patterns Mastered"
    assert html =~ "No patterns yet"
  end

  test "opens the QR code modal", %{conn: conn} do
    {:ok, live, html} = live(conn, ~p"/user_profile")

    refute html =~ "qr-modal"

    html = live |> element("div[phx-click=open_qr_modal]") |> render_click()

    assert html =~ "qr-modal"
    assert html =~ "Scan to connect with other dancers"
  end

  test "lists the user's patterns with their status", %{conn: conn, user: user} do
    pattern = pattern_fixture(%{name: "Whip"})
    user_pattern_fixture(%{user: user, pattern: pattern, status: "learned"})

    {:ok, _live, html} = live(conn, ~p"/user_profile")

    assert html =~ "Whip"
    assert html =~ "Learned"
    refute html =~ "No patterns yet"
  end
end
