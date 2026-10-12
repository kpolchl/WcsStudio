defmodule WcsStudio.CommentsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.Comment` context.
  """

  import WcsStudio.AccountsFixtures
  import WcsStudio.PostsFixtures

  def comment_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()
    post = Map.get(attrs, :post) || post_fixture()

    {:ok, comment} =
      WcsStudio.Comment.add(
        Map.get(attrs, :body, "A thoughtful comment."),
        user.id,
        post.id
      )

    comment
  end
end
