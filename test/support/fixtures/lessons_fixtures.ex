defmodule WcsStudio.LessonsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.Lesson` context.
  """

  import WcsStudio.DanceTypesFixtures
  import WcsStudio.LevelsFixtures

  def unique_lesson_title, do: "Lesson #{System.unique_integer([:positive])}"

  @doc """
  Creates a lesson.

  Optional attrs:
    * `:dance_type` - existing `%WcsStudio.DanceType{}` (created if absent)
    * `:level` - existing `%WcsStudio.Levels{}` (created if absent)
    * `:instructors` - list of `%WcsStudio.Accounts.User{}`
    * `:patterns` - list of `%WcsStudio.Pattern{}`
    * `:title`, `:place`, `:date`, `:lesson_vid_url`
  """
  def lesson_fixture(attrs \\ %{}) do
    dance_type = Map.get(attrs, :dance_type) || dance_type_fixture()
    level = Map.get(attrs, :level) || level_fixture()
    instructors = Map.get(attrs, :instructors, [])
    patterns = Map.get(attrs, :patterns, [])

    instructor_ids = Enum.map(instructors, & &1.id)
    pattern_ids = Enum.map(patterns, & &1.id)

    {:ok, lesson} =
      WcsStudio.Lesson.add(
        Map.get(attrs, :title, unique_lesson_title()),
        instructor_ids,
        pattern_ids,
        level.id,
        Map.get(attrs, :place, "Buma Square Business Park"),
        Map.get(attrs, :lesson_vid_url, ""),
        Map.get(attrs, :date, ~D[2024-01-01]),
        dance_type.id
      )

    lesson
  end
end
