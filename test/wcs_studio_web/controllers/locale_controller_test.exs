defmodule WcsStudioWeb.LocaleControllerTest do
  use WcsStudioWeb.ConnCase

  test "sets the locale and redirects to root", %{conn: conn} do
    conn = get(conn, ~p"/locale/en")

    assert redirected_to(conn) == "/"
    assert get_session(conn, :locale) == "en"
  end

  test "sets the locale and redirects to the given path", %{conn: conn} do
    conn = get(conn, ~p"/locale/pl?redirect_to=/patterns")

    assert redirected_to(conn) == "/patterns"
    assert get_session(conn, :locale) == "pl"
  end

  test "ignores unsupported locales", %{conn: conn} do
    conn = get(conn, ~p"/locale/fr")

    assert redirected_to(conn) == "/"
  end
end
