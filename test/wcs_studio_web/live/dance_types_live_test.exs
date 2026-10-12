defmodule WcsStudioWeb.DanceTypesLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.DanceTypesFixtures

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "renders all dance types", %{conn: conn} do
    dance_type = dance_type_fixture(%{name_en: "West Coast Swing", type: "swing"})

    {:ok, _live, html} = live(conn, ~p"/dance_types")

    assert html =~ "Dance Types"
    assert html =~ "West Coast Swing"
    assert html =~ dance_type.type
  end

  test "shows an empty state when there are no dance types", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/dance_types")

    assert html =~ "No dance types found"
  end

  test "filters dance types by type", %{conn: conn} do
    dance_type_fixture(%{name_en: "Salsa", type: "latin"})
    dance_type_fixture(%{name_en: "West Coast Swing", type: "swing"})

    {:ok, live, _html} = live(conn, ~p"/dance_types")

    html = live |> element("button[phx-value-dance_type_type=latin]") |> render_click()

    assert html =~ "Salsa"
    refute html =~ "West Coast Swing"
  end
end
