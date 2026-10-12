defmodule WcsStudio.UserLessonTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures
  import WcsStudio.LessonsFixtures
  import WcsStudio.UserLessonsFixtures

  alias WcsStudio.UserLesson

  describe "add/2" do
    test "creates a user lesson" do
      user = user_fixture()
      lesson = lesson_fixture()

      assert {:ok, user_lesson} = UserLesson.add(user.id, lesson.id)
      assert user_lesson.user_id == user.id
      assert user_lesson.lesson_id == lesson.id
    end

    test "requires a user and lesson" do
      assert {:error, changeset} = UserLesson.add(nil, nil)

      errors = errors_on(changeset)
      assert errors[:user_id]
      assert errors[:lesson_id]
    end

    test "enforces the unique user/lesson constraint" do
      user_lesson = user_lesson_fixture()

      assert {:error, changeset} =
               UserLesson.add(user_lesson.user_id, user_lesson.lesson_id)

      assert %{user_id: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "queries" do
    test "get_user_lessons/1 returns the user's lessons preloaded" do
      user = user_fixture()
      user_lesson = user_lesson_fixture(%{user: user})

      [found] = UserLesson.get_user_lessons(user.id)
      assert found.id == user_lesson.id
      assert %WcsStudio.Lesson{} = found.lesson
    end

    test "get_user_lesson/2 returns one record or nil" do
      user_lesson = user_lesson_fixture()

      assert UserLesson.get_user_lesson(user_lesson.user_id, user_lesson.lesson_id).id ==
               user_lesson.id

      assert UserLesson.get_user_lesson(-1, -1) == nil
    end

    test "get_chart_data/1 returns [total_lessons, attended]" do
      user = user_fixture()
      attended = lesson_fixture()
      _unattended = lesson_fixture()

      user_lesson_fixture(%{user: user, lesson: attended})

      assert UserLesson.get_chart_data(user.id) == [2, 1]
    end
  end

  describe "delete/1" do
    test "deletes the user lesson" do
      user_lesson = user_lesson_fixture()

      assert {:ok, _} = UserLesson.delete(user_lesson)
      assert UserLesson.get_user_lesson(user_lesson.user_id, user_lesson.lesson_id) == nil
    end
  end
end
