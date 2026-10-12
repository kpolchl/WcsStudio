defmodule WcsStudio.PatternTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.DanceTypesFixtures
  import WcsStudio.PatternsFixtures

  alias WcsStudio.Pattern

  describe "add/1" do
    test "creates a pattern with valid attributes" do
      attrs = pattern_attributes()

      assert {:ok, pattern} = Pattern.add(attrs)
      assert pattern.name == attrs.name
      assert pattern.starting_hands == :left_left
      assert pattern.ending_hands == :right_right
    end

    test "requires a name and a dance type" do
      assert {:error, changeset} = Pattern.add(%{})

      errors = errors_on(changeset)
      assert errors[:name]
      assert errors[:dance_type_id]
    end

    test "rejects an invalid starting_hands value" do
      attrs = Map.put(pattern_attributes(), :starting_hands, "sideways")

      assert {:error, changeset} = Pattern.add(attrs)
      assert %{starting_hands: ["is invalid"]} = errors_on(changeset)
    end

    test "does not allow a non-existent dance type" do
      attrs = Map.put(pattern_attributes(), :dance_type_id, -1)

      assert {:error, changeset} = Pattern.add(attrs)
      assert %{dance_type_id: [_]} = errors_on(changeset)
    end
  end

  describe "queries" do
    test "get_all/0 returns patterns preloaded with dance types" do
      pattern = pattern_fixture()
      found = Enum.find(Pattern.get_all(), &(&1.id == pattern.id))
      assert %WcsStudio.DanceType{} = found.dance_type
    end

    test "count_patterns/0 counts patterns" do
      assert Pattern.count_patterns() == 0
      pattern_fixture()
      assert Pattern.count_patterns() == 1
    end

    test "get_by_id/1 returns a pattern or nil" do
      pattern = pattern_fixture()
      assert Pattern.get_by_id(pattern.id).id == pattern.id
      assert Pattern.get_by_id(-1) == nil
    end

    test "get_by_dance_type_id/1 returns all patterns for a dance type" do
      dance_type = dance_type_fixture()
      pattern = pattern_fixture(%{dance_type: dance_type})

      ids = Pattern.get_by_dance_type_id(dance_type.id) |> Enum.map(& &1.id)
      assert pattern.id in ids
    end

    test "get_roots/1 returns only root patterns for a dance type" do
      dance_type = dance_type_fixture()
      root = pattern_fixture(%{dance_type: dance_type})
      child = pattern_fixture(%{dance_type: dance_type})
      {:ok, _} = Pattern.set_parent(child.id, root.id)

      root_ids = Pattern.get_roots(dance_type.id) |> Enum.map(& &1.id)
      assert root.id in root_ids
      refute child.id in root_ids
    end

    test "get_children/1 returns the children of a pattern" do
      parent = pattern_fixture()
      child = pattern_fixture(%{dance_type: dance_type_for(parent)})
      {:ok, _} = Pattern.set_parent(child.id, parent.id)

      assert Enum.map(Pattern.get_children(parent.id), & &1.id) == [child.id]
    end
  end

  describe "get_tree/1" do
    test "builds a nested tree with depth values" do
      root = pattern_fixture(%{name: "Root"})
      child = pattern_fixture(%{name: "Child", dance_type: dance_type_for(root)})
      grand_child = pattern_fixture(%{name: "Grandchild", dance_type: dance_type_for(root)})
      {:ok, _} = Pattern.set_parent(child.id, root.id)
      {:ok, _} = Pattern.set_parent(grand_child.id, child.id)

      tree = Pattern.get_tree(root.id)

      assert tree.id == root.id
      assert tree.depth == 0
      [tree_child] = tree.children
      assert tree_child.id == child.id
      assert tree_child.depth == 1
      [tree_grand_child] = tree_child.children
      assert tree_grand_child.id == grand_child.id
      assert tree_grand_child.depth == 2
    end

    test "returns nil for a missing root" do
      assert Pattern.get_tree(-1) == nil
    end
  end

  describe "set_parent/2 and remove_parent/1" do
    test "sets and removes a parent" do
      parent = pattern_fixture()
      child = pattern_fixture(%{dance_type: dance_type_for(parent)})

      assert {:ok, updated} = Pattern.set_parent(child.id, parent.id)
      assert updated.parent_id == parent.id

      assert {:ok, detached} = Pattern.remove_parent(child.id)
      assert detached.parent_id == nil
    end

    test "returns :not_found for an unknown child" do
      assert {:error, :not_found} = Pattern.set_parent(-1, 1)
      assert {:error, :not_found} = Pattern.remove_parent(-1)
    end
  end

  describe "tree helpers" do
    setup do
      dance_type = dance_type_fixture()
      root = pattern_fixture(%{name: "Alpha", dance_type: dance_type})
      child = pattern_fixture(%{name: "Alpha Variation", dance_type: dance_type})
      orphan = pattern_fixture(%{name: "Beta", dance_type: dance_type})
      {:ok, _} = Pattern.set_parent(child.id, root.id)

      %{dance_type: dance_type, root: root, child: child, orphan: orphan}
    end

    test "get_roots_with_children/1 includes children sorted by name", %{
      dance_type: dance_type,
      root: root,
      child: child
    } do
      [found] = Enum.filter(Pattern.get_roots_with_children(dance_type.id), &(&1.id == root.id))
      assert Enum.map(found.children, & &1.id) == [child.id]
    end

    test "get_roots_without_children/1 excludes roots with children", %{
      dance_type: dance_type,
      root: root,
      orphan: orphan
    } do
      ids = Pattern.get_roots_without_children(dance_type.id) |> Enum.map(& &1.id)
      assert orphan.id in ids
      refute root.id in ids
    end

    test "get_roots_for_dance_type/1 returns roots without preloads", %{
      dance_type: dance_type,
      root: root,
      orphan: orphan,
      child: child
    } do
      ids = Pattern.get_roots_for_dance_type(dance_type.id) |> Enum.map(& &1.id)
      assert root.id in ids
      assert orphan.id in ids
      refute child.id in ids
    end

    test "get_all_for_dance_type/1 returns roots and children", %{
      dance_type: dance_type,
      root: root,
      child: child
    } do
      ids = Pattern.get_all_for_dance_type(dance_type.id) |> Enum.map(& &1.id)
      assert root.id in ids
      assert child.id in ids
    end

    test "get_by_id_name_or_hands/2 returns matching roots with matching children", %{
      dance_type: dance_type,
      root: root,
      child: child
    } do
      results = Pattern.get_by_id_name_or_hands(dance_type.id, "Alpha")
      assert [found] = Enum.filter(results, &(&1.id == root.id))
      assert Enum.any?(found.children, &(&1.id == child.id))
    end

    test "get_by_id_name_or_hands/2 keeps the parent when only a child matches", %{
      dance_type: dance_type,
      root: root,
      child: child
    } do
      results = Pattern.get_by_id_name_or_hands(dance_type.id, "Variation")
      assert [found] = results
      assert found.id == root.id
      assert Enum.map(found.children, & &1.id) == [child.id]
    end
  end

  describe "update/2, delete_pattern/1 and helpers" do
    test "updates a pattern" do
      pattern = pattern_fixture()

      assert {:ok, updated} = Pattern.update(pattern, %{name: "Renamed"})
      assert updated.name == "Renamed"
    end

    test "deletes a pattern" do
      pattern = pattern_fixture()

      assert {:ok, _} = Pattern.delete_pattern(pattern.id)
      assert Pattern.get_by_id(pattern.id) == nil
    end

    test "delete_pattern/1 returns :not_found for an unknown id" do
      assert {:error, :not_found} = Pattern.delete_pattern(-1)
    end

    test "get_by_id_with_children/1 preloads children" do
      parent = pattern_fixture()
      child = pattern_fixture(%{dance_type: dance_type_for(parent)})
      {:ok, _} = Pattern.set_parent(child.id, parent.id)

      found = Pattern.get_by_id_with_children(parent.id)
      assert Enum.map(found.children, & &1.id) == [child.id]
    end

    test "hands_options/0 returns the four hand positions" do
      assert Pattern.hands_options() == [
               {"Left / Left", :left_left},
               {"Left / Right", :left_right},
               {"Right / Right", :right_right},
               {"Right / Left", :right_left}
             ]
    end
  end

  defp dance_type_for(%{dance_type_id: id}), do: dance_type_from_id(id)

  defp dance_type_from_id(id), do: WcsStudio.Repo.get!(WcsStudio.DanceType, id)
end
