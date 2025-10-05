defmodule WcsStudio.Post do
  @moduledoc
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :user, WcsStudio.Accounts.User
    has_many :comments , WcsStudio.Comment
    timestamps()
  end
  @doc """
  Returns all posts from the database, preloading associated comments.
  """
  def get_all() do
    WcsStudio.Post
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:comments)
    |> WcsStudio.Repo.preload(:user)
  end

  def get_post_by_id(id) do
    WcsStudio.Post
    |> where(id: ^id)
    |> WcsStudio.Repo.one()
  end

  def get_post_comments(post_id) do
    WcsStudio.Post
    |> where(id: ^post_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:comments)

  end

  def update_post(post, new_title ,new_body) do
    post
    |> changeset(%{title: new_title, body: new_body})
    |> WcsStudio.Repo.update()
  end

  def add(title, body, user_id) do
    %__MODULE__{}
    |> changeset(%{title: title, body: body, user_id: user_id})
    |> WcsStudio.Repo.insert()
  end

  def delete_post(post) do
    WcsStudio.Repo.delete(post)
  end

  defp changeset(post, params \\ %{}) do
    post
    |> cast(params , [:title, :body, :user_id])
    |> validate_required([:title, :body, :user_id])
    |> foreign_key_constraint(:user_id)
  end

end

