defmodule WcsStudio.PostsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.Post` context.
  """

  import WcsStudio.AccountsFixtures

  def unique_post_title, do: "Post #{System.unique_integer([:positive])}"

  def valid_post_attributes(attrs \\ %{}) do
    {user, attrs} = Map.pop(attrs, :user, nil)

    Enum.into(attrs, %{
      title: unique_post_title(),
      subject: "Subject",
      body: "A body with some words in it.",
      tags: "swing:westcoast",
      user_id: (user || user_fixture()).id
    })
  end

  def post_fixture(attrs \\ %{}) do
    attrs = valid_post_attributes(attrs)

    {:ok, post} =
      WcsStudio.Post.add(
        attrs.title,
        attrs.subject,
        attrs.body,
        attrs.tags,
        attrs.user_id
      )

    post
  end
end
