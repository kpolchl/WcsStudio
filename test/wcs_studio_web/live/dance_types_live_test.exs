defmodule WcsStudioWeb.DanceTypesLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
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

  test "clicking a dance type opens patterns with that type selected", %{conn: conn} do
    dance_type_fixture(%{name_en: "West Coast Swing", type: "swing"})
    samba = dance_type_fixture(%{name_en: "Samba", type: "latin"})

    samba_path = "/patterns?dance_type_id=#{samba.id}"
    {:ok, live, html} = live(conn, ~p"/dance_types")

    assert html =~ ~s(href="#{samba_path}")

    result = live |> element(~s(a[href="#{samba_path}"])) |> render_click()

    assert {:error, {:live_redirect, %{to: ^samba_path}}} = result

    {:ok, _patterns, html} = follow_redirect(result, conn, samba_path)

    # Samba is the selected dance type in the patterns filter, not the default
    # (West Coast Swing).
    assert html =~ "Samba"
    refute html =~ "West Coast Swing"
  end

  test "uses the persisted image URL", %{conn: conn} do
    dance_type_fixture(%{
      name_en: "Viennese Waltz",
      type: "standard",
      pic_url: "/images/Vienna-Valtz.webp"
    })

    {:ok, _live, html} = live(conn, ~p"/dance_types")

    assert html =~ ~s(src="/images/Vienna-Valtz.webp")
  end

  test "falls back to a default image when no image URL is stored", %{conn: conn} do
    dance_type_fixture(%{name_en: "Salsa", type: "latin"})

    {:ok, _live, html} = live(conn, ~p"/dance_types")

    assert html =~ ~s(src="/images/dance-971082_1280.webp")
  end

  test "does not show the add button to anonymous visitors", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/dance_types")

    refute html =~ "Add New Dance Type"
  end

  test "an admin can create a dance type", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture(role: "admin"))
      |> put_session(:locale, "en")

    {:ok, live, html} = live(conn, ~p"/dance_types")
    assert html =~ "Add New Dance Type"

    live |> element("button[phx-click=open_modal]") |> render_click()
    assert render(live) =~ "new-dance-type-modal"

    html =
      live
      |> form("form[phx-submit=save]",
        dance_type: %{
          name_en: "Bachata",
          description_en: "A social partner dance.",
          type: "social",
          pic_url: "/images/Vienna-Valtz.webp"
        }
      )
      |> render_submit()

    assert html =~ "Bachata"

    created =
      WcsStudio.DanceType.get_all()
      |> Enum.find(&(&1.name_en == "Bachata"))

    assert created.name_pl == "Bachata"
  end
end
