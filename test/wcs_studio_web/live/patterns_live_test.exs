defmodule WcsStudioWeb.PatternsLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures
  import WcsStudio.PatternsFixtures

  setup %{conn: conn} do
    dance_type = dance_type_fixture()

    %{conn: init_test_session(conn, %{"locale" => "en"}), dance_type: dance_type}
  end

  test "renders patterns for anonymous visitors", %{conn: conn, dance_type: dance_type} do
    pattern_fixture(%{dance_type: dance_type, name: "Alpha Step"})

    {:ok, _live, html} = live(conn, ~p"/patterns")

    assert html =~ "Steps"
    assert html =~ "Alpha Step"
    refute html =~ "Add New Pattern"
  end

  test "shows the empty state when there are no patterns", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/patterns")

    assert html =~ "No patterns found"
  end

  test "an admin can create a pattern", %{conn: conn, dance_type: dance_type} do
    conn =
      conn
      |> log_in_user(user_fixture(role: "admin"))
      |> put_session(:locale, "en")

    {:ok, live, html} = live(conn, ~p"/patterns")
    assert html =~ "Add New Pattern"

    live |> element("button[phx-click=open_modal]") |> render_click()
    assert render(live) =~ "new-pattern-modal"

    assert {:error, {:live_redirect, %{to: "/patterns"}}} =
             live
             |> form("form[phx-submit=save]", pattern: %{name: "New Step", count_num: "8"})
             |> render_submit()

    assert WcsStudio.Pattern.get_all_for_dance_type(dance_type.id)
           |> Enum.any?(&(&1.name == "New Step"))
  end

  test "search filters the displayed patterns", %{conn: conn, dance_type: dance_type} do
    pattern_fixture(%{dance_type: dance_type, name: "Alpha Step"})
    pattern_fixture(%{dance_type: dance_type, name: "Beta Step"})

    {:ok, live, _html} = live(conn, ~p"/patterns")

    html = live |> form("form[phx-change=search]", query: "Alpha") |> render_change()

    assert html =~ "Alpha Step"
    refute html =~ "Beta Step"
  end

  test "a logged in user can update a pattern status", %{conn: conn, dance_type: dance_type} do
    user = user_fixture()
    pattern = pattern_fixture(%{dance_type: dance_type, name: "Whip"})

    conn = conn |> log_in_user(user) |> put_session(:locale, "en")

    {:ok, live, _html} = live(conn, ~p"/patterns")

    html = live |> element("button[phx-click=update_status]") |> render_click()

    assert html =~ "Status updated to in_progress!"
    assert WcsStudio.UserPattern.get_user_pattern(user.id, pattern.id).status == "in_progress"
  end
end
