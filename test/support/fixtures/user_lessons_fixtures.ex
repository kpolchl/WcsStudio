defmodule WcsStudio.UserLessonsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.UserLesson` context.
  """

  import WcsStudio.AccountsFixtures
  import WcsStudio.LessonsFixtures

  def user_lesson_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()
    lesson = Map.get(attrs, :lesson) || lesson_fixture()

    {:ok, user_lesson} = WcsStudio.UserLesson.add(user.id, lesson.id)

    user_lesson
  end
end
