defmodule WcsStudio.LessonTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures
  import WcsStudio.LessonsFixtures
  import WcsStudio.LevelsFixtures
  import WcsStudio.PatternsFixtures

  alias WcsStudio.Lesson

  describe "add/8" do
    test "creates a lesson" do
      dance_type = dance_type_fixture()
      level = level_fixture()
      instructor = user_fixture()
      pattern = pattern_fixture(%{dance_type: dance_type})

      assert {:ok, lesson} =
               Lesson.add(
                 "Whip Workshop",
                 [instructor.id],
                 [pattern.id],
                 level.id,
                 "Buma Square",
                 "https://www.youtube.com/embed/abc",
                 ~D[2024-05-01],
                 dance_type.id
               )

      assert lesson.title == "Whip Workshop"
      assert Enum.map(lesson.instructors, & &1.id) == [instructor.id]
      assert Enum.map(lesson.patterns, & &1.id) == [pattern.id]
    end

    test "requires title, level, place, date and dance type" do
      assert {:error, changeset} = Lesson.add(nil, [], [], nil, nil, nil, nil, nil)

      errors = errors_on(changeset)

      for field <- [:title, :level_id, :place, :date, :dance_type_id] do
        assert errors[field]
      end
    end
  end

  describe "queries" do
    test "get_by_id/1 returns a fully preloaded lesson" do
      lesson = lesson_fixture()

      found = Lesson.get_by_id(lesson.id)
      assert found.id == lesson.id
      assert %WcsStudio.Levels{} = found.level
      assert %WcsStudio.DanceType{} = found.dance_type
      assert is_list(found.instructors)
      assert is_list(found.patterns)
    end

    test "get_by_id/1 returns nil for an unknown id" do
      assert Lesson.get_by_id(-1) == nil
    end

    test "get_all/0 returns all lessons preloaded" do
      lesson = lesson_fixture()
      assert Enum.any?(Lesson.get_all(), &(&1.id == lesson.id))
    end

    test "count_lessons/0 counts lessons" do
      assert Lesson.count_lessons() == 0
      lesson_fixture()
      assert Lesson.count_lessons() == 1
    end

    test "get_first/0 returns the first lesson" do
      lesson = lesson_fixture()
      assert Lesson.get_first().id == lesson.id
    end

    test "get_first/0 falls back to a placeholder map when empty" do
      assert Lesson.get_first() == %{dance_type_id: 1, level_id: 1}
    end

    test "get_by_dance_type_and_level/2 filters and orders by date" do
      dance_type = dance_type_fixture()
      level = level_fixture()
      later = lesson_fixture(%{dance_type: dance_type, level: level, date: ~D[2024-06-01]})
      earlier = lesson_fixture(%{dance_type: dance_type, level: level, date: ~D[2024-01-01]})
      _other = lesson_fixture(%{dance_type: dance_type_fixture(), level: level})

      assert Enum.map(Lesson.get_by_dance_type_and_level(dance_type.id, level.id), & &1.id) ==
               [earlier.id, later.id]
    end

    test "get_by_level_id/2 filters an in-memory list" do
      level = level_fixture()
      lesson = lesson_fixture(%{level: level})

      assert Lesson.get_by_level_id([lesson], level.id) == [lesson]
      assert Lesson.get_by_level_id([lesson], -1) == []
    end
  end

  describe "update/2" do
    test "updates the lesson and its associations" do
      lesson = lesson_fixture()
      pattern = pattern_fixture(%{dance_type: dance_type_fixture()})

      attrs = %{
        title: "Updated",
        level_id: lesson.level_id,
        place: "New Place",
        lesson_vid_url: "",
        date: ~D[2024-02-02],
        dance_type_id: lesson.dance_type_id,
        instructor_ids: [],
        pattern_ids: [pattern.id]
      }

      assert {:ok, updated} = Lesson.update(lesson, attrs)
      assert updated.title == "Updated"
      assert Enum.map(updated.patterns, & &1.id) == [pattern.id]
    end

    test "accepts string ids" do
      lesson = lesson_fixture()
      pattern = pattern_fixture(%{dance_type: dance_type_fixture()})

      attrs = %{
        title: lesson.title,
        level_id: lesson.level_id,
        place: lesson.place,
        lesson_vid_url: "",
        date: lesson.date,
        dance_type_id: lesson.dance_type_id,
        instructor_ids: [],
        pattern_ids: [Integer.to_string(pattern.id)]
      }

      assert {:ok, updated} = Lesson.update(lesson, attrs)
      assert Enum.map(updated.patterns, & &1.id) == [pattern.id]
    end
  end

  describe "delete_lesson/1" do
    test "deletes a lesson" do
      lesson = lesson_fixture()

      assert {:ok, _} = Lesson.delete_lesson(lesson.id)
      assert Lesson.get_by_id(lesson.id) == nil
    end

    test "returns :not_found for an unknown id" do
      assert {:error, :not_found} = Lesson.delete_lesson(-1)
    end
  end
end
