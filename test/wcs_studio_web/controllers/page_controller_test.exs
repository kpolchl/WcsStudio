defmodule WcsStudioWeb.PageControllerTest do
  use WcsStudioWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Master the art of movement"
  end
end
