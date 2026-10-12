defmodule WcsStudio.LevelsTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.LevelsFixtures

  alias WcsStudio.Levels

  describe "add/1" do
    test "creates a level from a name" do
      assert {:ok, level} = Levels.add("Advanced")
      assert level.name == "Advanced"
    end

    test "rejects a blank name" do
      assert {:error, changeset} = Levels.add(nil)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "enforces the unique name constraint" do
      level = level_fixture()

      assert {:error, changeset} = Levels.add(level.name)
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "get_all/0" do
    test "returns all levels" do
      level = level_fixture()
      assert Enum.any?(Levels.get_all(), &(&1.id == level.id))
    end
  end
end
