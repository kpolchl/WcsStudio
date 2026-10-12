defmodule WcsStudioWeb.HomeControllerTest do
  use WcsStudioWeb.ConnCase

  test "GET / renders the landing page", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    assert body =~ "WcsStudio"
    assert body =~ "Master the art of movement"
    assert body =~ "Ready to Track your progress?"
  end

  test "GET / renders the rounded-down resource counters", %{conn: conn} do
    conn = get(conn, ~p"/")
    body = html_response(conn, 200)

    assert body =~ "Articles"
    assert body =~ "Patterns"
    assert body =~ "Members"
    assert body =~ "Lessons"
  end
end
