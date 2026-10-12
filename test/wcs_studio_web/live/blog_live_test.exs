defmodule WcsStudioWeb.BlogLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.PostsFixtures

  setup %{conn: conn} do
    %{conn: init_test_session(conn, %{"locale" => "en"})}
  end

  test "renders the blog heading and existing posts", %{conn: conn} do
    post = post_fixture()

    {:ok, _live, html} = live(conn, ~p"/blog")

    assert html =~ "Blog"
    assert html =~ post.title
  end

  test "does not show the add button to anonymous visitors", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/blog")

    refute html =~ "Add New Pattern"
  end

  test "admin can open the modal and create a post", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture(role: "admin"))
      |> put_session(:locale, "en")

    {:ok, live, _html} = live(conn, ~p"/blog")

    live |> element("button[phx-click=open_modal]") |> render_click()
    assert render(live) =~ "new-post-modal"

    assert {:error, {:live_redirect, %{to: "/blog"}}} =
             live
             |> element("#new-post-modal form")
             |> render_submit(%{
               "post" => %{
                 "title" => "A New Post",
                 "subject" => "Subject",
                 "body" => "Some body text",
                 "tags" => ":swing:"
               }
             })

    assert [post] = WcsStudio.Post.get_all()
    assert post.title == "A New Post"
  end
end
