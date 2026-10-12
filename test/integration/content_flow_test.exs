defmodule WcsStudio.Integration.ContentFlowTest do
  @moduledoc """
  Cross-feature journeys that drive the admin and dancer experiences through the
  LiveView UI and verify the resulting persisted state.
  """
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "an admin creates a pattern and a dancer tracks it end to end", %{conn: conn} do
    dance_type = dance_type_fixture()

    # --- Admin prepares content -------------------------------------------------
    admin_conn = conn |> log_in_user(user_fixture(role: "admin")) |> put_session(:locale, "en")

    {:ok, lv, html} = live(admin_conn, ~p"/patterns")
    assert html =~ "Add New Pattern"

    lv |> element("button[phx-click=open_modal]") |> render_click()

    assert {:error, {:live_redirect, %{to: "/patterns"}}} =
             lv
             |> form("form[phx-submit=save]", pattern: %{name: "Sugar Push", count_num: "6"})
             |> render_submit()

    assert [pattern] = WcsStudio.Pattern.get_all_for_dance_type(dance_type.id)
    assert pattern.name == "Sugar Push"

    # --- Dancer discovers and tracks the pattern --------------------------------
    dancer = user_fixture(username: "dancer")
    dancer_conn = conn |> log_in_user(dancer) |> put_session(:locale, "en")

    {:ok, lv, html} = live(dancer_conn, ~p"/patterns")
    assert html =~ "Sugar Push"

    assert lv |> element("button[phx-click=update_status]") |> render_click() =~
             "Status updated to in_progress!"

    assert WcsStudio.UserPattern.get_user_pattern(dancer.id, pattern.id).status == "in_progress"

    # The progress shows up on the profile dashboard.
    {:ok, _lv, html} = live(dancer_conn, ~p"/user_profile")
    assert html =~ "Sugar Push"
    assert html =~ "In Progress"

    # ...and the pattern is reachable through the practice picker.
    {:ok, lv, _html} = live(dancer_conn, ~p"/practice")
    assert lv |> element("button[phx-click=random_practice]") |> render_click() =~ "Sugar Push"
  end

  test "the admin-only lessons area rejects non-admin sessions", %{conn: conn} do
    # Non-admin authenticated user is redirected away.
    dancer_conn = conn |> log_in_user(user_fixture()) |> put_session(:locale, "en")
    assert {:error, {:redirect, %{to: "/"}}} = live(dancer_conn, ~p"/admin/lessons")

    # Anonymous visitor is sent to the login page.
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/admin/lessons")
  end

  test "a blog post can be created, commented on and deleted", %{conn: conn} do
    admin_conn = conn |> log_in_user(user_fixture(role: "admin")) |> put_session(:locale, "en")

    # --- Admin writes a post ----------------------------------------------------
    {:ok, lv, _html} = live(admin_conn, ~p"/blog")
    lv |> element("button[phx-click=open_modal]") |> render_click()

    assert {:error, {:live_redirect, %{to: "/blog"}}} =
             lv
             |> element("#new-post-modal form")
             |> render_submit(%{
               "post" => %{
                 "title" => "Flow Post",
                 "subject" => "Hello",
                 "body" => "A body worth reading",
                 "tags" => ":swing:"
               }
             })

    post = WcsStudio.Post.get_all() |> List.first()
    assert post.title == "Flow Post"

    # --- A dancer comments on it ------------------------------------------------
    dancer_conn =
      conn |> log_in_user(user_fixture(username: "commenter")) |> put_session(:locale, "en")

    {:ok, lv, _html} = live(dancer_conn, ~p"/blog/#{post.id}")

    assert lv
           |> form("form[phx-submit=add_comment]", comment: %{body: "Loved it"})
           |> render_submit() =~ "Loved it"

    # --- Admin removes it -------------------------------------------------------
    {:ok, lv, _html} = live(admin_conn, ~p"/blog/#{post.id}")

    assert {:error, {:live_redirect, %{to: "/blog"}}} =
             lv |> element("button[phx-click=delete_post]") |> render_click()

    assert WcsStudio.Post.get_post_by_id(post.id) == nil
  end
end
