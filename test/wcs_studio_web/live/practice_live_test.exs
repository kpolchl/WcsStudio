defmodule WcsStudioWeb.PracticeLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures
  import WcsStudio.PatternsFixtures

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "renders for anonymous visitors with only the all filter", %{conn: conn} do
    dance_type_fixture()

    {:ok, _live, html} = live(conn, ~p"/practice")

    assert html =~ "Practice"
    assert html =~ "Start Practice"
    refute html =~ "In Progress"
    refute html =~ "Learned"
  end

  test "start practice draws random patterns", %{conn: conn} do
    dance_type = dance_type_fixture()
    pattern_fixture(%{dance_type: dance_type, name: "Alpha Step"})
    pattern_fixture(%{dance_type: dance_type, name: "Beta Step"})

    {:ok, live, _html} = live(conn, ~p"/practice")

    html = live |> element("button[phx-click=random_practice]") |> render_click()

    assert html =~ "Alpha Step"
    assert html =~ "Beta Step"
  end

  test "a logged in user sees the status filters", %{conn: conn} do
    dance_type_fixture()

    conn =
      conn
      |> log_in_user(user_fixture())
      |> put_session(:locale, "en")

    {:ok, _live, html} = live(conn, ~p"/practice")

    assert html =~ "In Progress"
    assert html =~ "Learned"
  end
end
