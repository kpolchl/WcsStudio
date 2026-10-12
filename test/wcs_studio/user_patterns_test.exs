defmodule WcsStudio.UserPatternTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures
  import WcsStudio.DanceTypesFixtures
  import WcsStudio.PatternsFixtures
  import WcsStudio.UserPatternsFixtures

  alias WcsStudio.UserPattern

  describe "add/3" do
    test "creates a user pattern" do
      user = user_fixture()
      pattern = pattern_fixture()

      assert {:ok, user_pattern} = UserPattern.add(pattern.id, user.id, "in_progress")
      assert user_pattern.status == "in_progress"
    end

    test "requires a status, pattern and user" do
      assert {:error, changeset} = UserPattern.add(nil, nil, nil)

      errors = errors_on(changeset)
      assert errors[:pattern_id]
      assert errors[:user_id]
      assert errors[:status]
    end
  end

  describe "queries" do
    test "get_user_patterns/1 returns the user's patterns preloaded" do
      user = user_fixture()
      user_pattern = user_pattern_fixture(%{user: user})

      [found] = UserPattern.get_user_patterns(user.id)
      assert found.id == user_pattern.id
      assert %WcsStudio.Pattern{} = found.pattern
      assert %WcsStudio.DanceType{} = found.pattern.dance_type
    end

    test "get_user_pattern/2 returns one record or nil" do
      user_pattern = user_pattern_fixture()
      user_id = user_pattern.user_id
      pattern_id = user_pattern.pattern_id

      assert UserPattern.get_user_pattern(user_id, pattern_id).id == user_pattern.id
      assert UserPattern.get_user_pattern(-1, -1) == nil
    end

    test "get_chart_data/1 returns [not_learned, in_progress, learned]" do
      user = user_fixture()
      dance_type = dance_type_fixture()
      p1 = pattern_fixture(%{dance_type: dance_type})
      p2 = pattern_fixture(%{dance_type: dance_type})
      _p3 = pattern_fixture(%{dance_type: dance_type})

      user_pattern_fixture(%{user: user, pattern: p1, status: "in_progress"})
      user_pattern_fixture(%{user: user, pattern: p2, status: "learned"})

      assert UserPattern.get_chart_data(user.id) == [1, 1, 1]
    end

    test "get_user_patterns_by_status_and_dance_type/3 filters by status" do
      user = user_fixture()
      dance_type = dance_type_fixture()
      learned = pattern_fixture(%{dance_type: dance_type})
      in_progress = pattern_fixture(%{dance_type: dance_type})

      user_pattern_fixture(%{user: user, pattern: learned, status: "learned"})
      user_pattern_fixture(%{user: user, pattern: in_progress, status: "in_progress"})

      all_ids =
        UserPattern.get_user_patterns_by_status_and_dance_type(user.id, "all", dance_type.id)
        |> Enum.map(& &1.id)

      assert learned.id in all_ids
      assert in_progress.id in all_ids

      learned_ids =
        UserPattern.get_user_patterns_by_status_and_dance_type(user.id, "learned", dance_type.id)
        |> Enum.map(& &1.id)

      assert learned_ids == [learned.id]
    end
  end

  describe "update_status/4" do
    test "updates the status" do
      user_pattern = user_pattern_fixture(%{status: "in_progress"})

      assert {:ok, updated} =
               UserPattern.update_status(
                 user_pattern,
                 user_pattern.pattern_id,
                 user_pattern.user_id,
                 "learned"
               )

      assert updated.status == "learned"
    end
  end
end
