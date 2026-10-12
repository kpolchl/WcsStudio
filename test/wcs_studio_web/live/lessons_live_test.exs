defmodule WcsStudioWeb.LessonsLiveTest do
  use WcsStudioWeb.ConnCase

  import Phoenix.LiveViewTest
  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures
  import WcsStudio.LevelsFixtures
  import WcsStudio.LessonsFixtures

  setup %{conn: conn} do
    dance_type = dance_type_fixture()
    level = level_fixture()

    lesson =
      lesson_fixture(%{dance_type: dance_type, level: level, title: "Beginner Bootcamp"})

    %{conn: init_test_session(conn, %{"locale" => "en"}), lesson: lesson}
  end

  test "redirects anonymous visitors to the login page", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/admin/lessons")
  end

  test "redirects non-admin users", %{conn: conn} do
    conn = conn |> log_in_user(user_fixture()) |> put_session(:locale, "en")

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/admin/lessons")
  end

  test "an admin can create a lesson", %{conn: conn} do
    conn = conn |> log_in_user(user_fixture(role: "admin")) |> put_session(:locale, "en")

    {:ok, live, html} = live(conn, ~p"/admin/lessons")
    assert html =~ "Lesson"
    assert html =~ "Add New Lesson"

    live |> element("button[phx-click=open_modal]") |> render_click()
    assert render(live) =~ "new-lesson-modal"

    assert {:error, {:live_redirect, %{to: "/admin/lessons"}}} =
             live
             |> form("form[phx-submit=save]", %{
               "lesson" => %{
                 "title" => "Advanced Workshop",
                 "place" => "Buma Square Business Park, Wadowicka 6",
                 "date" => "2024-05-01"
               }
             })
             |> render_submit()

    assert WcsStudio.Lesson.get_all() |> Enum.any?(&(&1.title == "Advanced Workshop"))
  end

  test "an admin can toggle attendance", %{conn: conn, lesson: lesson} do
    user = user_fixture(role: "admin")
    conn = conn |> log_in_user(user) |> put_session(:locale, "en")

    {:ok, live, html} = live(conn, ~p"/admin/lessons")
    assert html =~ "Beginner Bootcamp"

    html = live |> element("button[phx-click=toggle_attendance]") |> render_click()

    assert html =~ "Attendance marked!"
    assert WcsStudio.UserLesson.get_user_lesson(user.id, lesson.id)

    html = live |> element("button[phx-click=toggle_attendance]") |> render_click()

    assert html =~ "Attendance removed!"
    refute WcsStudio.UserLesson.get_user_lesson(user.id, lesson.id)
  end
end
