defmodule WcsStudio.Integration.LocaleFlowTest do
  @moduledoc """
  Verifies that a locale chosen on one request persists into subsequent
  requests and LiveView navigations.
  """
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.DanceTypesFixtures

  setup %{conn: conn} do
    dance_type = dance_type_fixture()

    %{conn: init_test_session(conn, %{"locale" => "en"}), dance_type: dance_type}
  end

  test "an English session renders English copy", %{conn: conn} do
    {:ok, _lv, html} = live(conn, ~p"/patterns")

    assert html =~ "Steps"
    refute html =~ "Kroki"
  end

  test "choosing Polish on a request carries over to LiveView pages", %{conn: conn} do
    conn = get(conn, ~p"/locale/pl")
    assert redirected_to(conn) == "/"
    assert get_session(conn, :locale) == "pl"

    {:ok, _lv, html} = live(conn, ~p"/patterns")
    assert html =~ "Kroki"
  end

  test "an unsupported locale falls back to the default page", %{conn: conn} do
    conn = get(conn, ~p"/locale/fr")
    assert redirected_to(conn) == "/"
  end
end
