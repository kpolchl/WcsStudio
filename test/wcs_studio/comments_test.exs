defmodule WcsStudio.CommentTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures
  import WcsStudio.CommentsFixtures
  import WcsStudio.PostsFixtures

  alias WcsStudio.Comment

  describe "add/3" do
    test "creates a comment" do
      user = user_fixture()
      post = post_fixture()

      assert {:ok, comment} = Comment.add("Nice post!", user.id, post.id)
      assert comment.body == "Nice post!"
      assert comment.user_id == user.id
      assert comment.post_id == post.id
    end

    test "requires a body, user and post" do
      assert {:error, changeset} = Comment.add(nil, nil, nil)

      errors = errors_on(changeset)
      assert errors[:body]
      assert errors[:user_id]
      assert errors[:post_id]
    end
  end

  describe "delete_comment/1" do
    test "deletes the comment" do
      comment = comment_fixture()
      assert {:ok, _} = Comment.delete_comment(comment)
      assert WcsStudio.Repo.get(Comment, comment.id) == nil
    end
  end
end
