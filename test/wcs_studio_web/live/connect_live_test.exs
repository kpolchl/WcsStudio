defmodule WcsStudioWeb.ConnectLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "renders the about and contact sections", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/connect")

    assert html =~ "Karol Półchłopek"
    assert html =~ "Get In Touch"
    assert html =~ "mailto:karol.szarooki@gmail.com"
  end

  test "sends a contact message and shows a confirmation", %{conn: conn} do
    {:ok, live, _html} = live(conn, ~p"/connect")

    assert {:error, {:live_redirect, %{to: "/connect"}}} =
             live
             |> form("form[phx-submit=send_message]", %{
               name: "Jane",
               email: "jane@example.com",
               message: "Hello there"
             })
             |> render_submit()

    assert_email_sent(subject: "💬 New message from Jane")
  end
end
