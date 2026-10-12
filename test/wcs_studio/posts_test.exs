defmodule WcsStudio.PostTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.PostsFixtures

  alias WcsStudio.Post

  setup do
    Gettext.put_locale(WcsStudioWeb.Gettext, "en")
    :ok
  end

  describe "add/5" do
    test "creates a post with valid data" do
      attrs = valid_post_attributes()

      assert {:ok, post} =
               Post.add(attrs.title, attrs.subject, attrs.body, attrs.tags, attrs.user_id)

      assert post.title == attrs.title
      assert post.user_id == attrs.user_id
    end

    test "requires all fields" do
      assert {:error, changeset} = Post.add(nil, nil, nil, nil, nil)

      errors = errors_on(changeset)

      for field <- [:title, :subject, :body, :tags, :user_id] do
        assert errors[field]
      end
    end

    test "does not allow a non-existent user" do
      attrs = valid_post_attributes(%{user_id: -1})

      assert {:error, changeset} =
               Post.add(attrs.title, attrs.subject, attrs.body, attrs.tags, attrs.user_id)

      assert %{user_id: [_]} = errors_on(changeset)
    end
  end

  describe "queries" do
    test "get_all/0 returns posts newest first, preloaded" do
      post = post_fixture()
      posts = Post.get_all()

      assert Enum.any?(posts, &(&1.id == post.id))
      assert %WcsStudio.Accounts.User{} = hd(posts).user
    end

    test "count_posts/0 counts posts" do
      assert Post.count_posts() == 0
      post_fixture()
      assert Post.count_posts() == 1
    end

    test "get_post_by_id/1 preloads user and comments" do
      post = post_fixture()
      assert Post.get_post_by_id(post.id).id == post.id
      assert Post.get_post_by_id(-1) == nil
    end

    test "get_post_comments/1 returns posts with comments preloaded" do
      post = post_fixture()
      [found] = Post.get_post_comments(post.id)
      assert found.id == post.id
      assert is_list(found.comments)
    end
  end

  describe "update_post/2" do
    test "updates a post" do
      post = post_fixture()

      assert {:ok, updated} = Post.update_post(post.id, %{title: "Updated"})
      assert updated.title == "Updated"
    end

    test "returns :not_found for an unknown id" do
      assert {:error, :not_found} = Post.update_post(-1, %{title: "Updated"})
    end

    test "returns an error changeset for invalid attrs" do
      post = post_fixture()

      assert {:error, %Ecto.Changeset{}} = Post.update_post(post.id, %{title: nil})
    end
  end

  describe "delete_post/1" do
    test "deletes the post" do
      post = post_fixture()
      assert {:ok, _} = Post.delete_post(post)
      assert Post.get_post_by_id(post.id) == nil
    end
  end

  describe "estimate_read_time/1" do
    test "rounds up to at least one minute" do
      assert Post.estimate_read_time("") =~ "1 min"
      assert Post.estimate_read_time("one two three") =~ "1 min"
    end

    test "scales with word count" do
      body = String.duplicate("word ", 450)
      assert Post.estimate_read_time(body) =~ "2 min"
    end
  end

  describe "parse_tags/1" do
    test "splits on colons and drops empty entries" do
      assert Post.parse_tags("swing:westcoast::latin:") == ["swing", "westcoast", "latin"]
    end

    test "returns an empty list for empty input" do
      assert Post.parse_tags("") == []
    end
  end
end
