defmodule WcsStudioWeb.BlogPostLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.PostsFixtures

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "redirects to the blog when the post does not exist", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/blog"}}} = live(conn, ~p"/blog/999999")
  end

  test "renders the post and its comments section", %{conn: conn} do
    post = post_fixture()

    {:ok, _live, html} = live(conn, ~p"/blog/#{post.id}")

    assert html =~ post.title
    assert html =~ "Back to Blog"
    assert html =~ "Comments"
    assert html =~ "No comments yet"
  end

  test "a logged in user can add a comment", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture(username: "commenter"))
      |> put_session(:locale, "en")

    post = post_fixture()

    {:ok, live, _html} = live(conn, ~p"/blog/#{post.id}")

    html =
      live
      |> form("form[phx-submit=add_comment]", comment: %{body: "Great article"})
      |> render_submit()

    assert html =~ "Great article"
  end

  test "an anonymous visitor is asked to sign in to comment", %{conn: conn} do
    post = post_fixture()

    {:ok, _live, html} = live(conn, ~p"/blog/#{post.id}")

    assert html =~ "Sign in to leave a comment"
  end

  test "an admin can edit a post", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture(role: "admin"))
      |> put_session(:locale, "en")

    post = post_fixture()

    {:ok, live, html} = live(conn, ~p"/blog/#{post.id}")
    assert html =~ "Edit Post"

    live |> element("button[phx-click=edit_post]") |> render_click()

    html =
      live
      |> form("form[phx-submit=update_post]", %{
        "post" => %{
          "title" => "An Updated Title",
          "subject" => "Subject",
          "body" => "Updated body",
          "tags" => ":swing:"
        }
      })
      |> render_submit()

    assert html =~ "An Updated Title"
    assert WcsStudio.Post.get_post_by_id(post.id).title == "An Updated Title"
  end

  test "an admin can delete a post", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture(role: "admin"))
      |> put_session(:locale, "en")

    post = post_fixture()

    {:ok, live, _html} = live(conn, ~p"/blog/#{post.id}")

    assert {:error, {:live_redirect, %{to: "/blog"}}} =
             live |> element("button[phx-click=delete_post]") |> render_click()

    assert WcsStudio.Post.get_post_by_id(post.id) == nil
  end
end
