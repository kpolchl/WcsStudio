defmodule WcsStudio.Post do
  @moduledoc
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  import WcsStudioWeb.Gettext

  schema "posts" do
    field :title, :string
    field :body, :string
    field :subject, :string
    field :tags, :string
    belongs_to :user, WcsStudio.Accounts.User
    has_many :comments , WcsStudio.Comment
    timestamps()
  end
  @doc """
  Returns all posts from the database, preloading associated comments.
  """
  def get_all do
    from(p in WcsStudio.Post,
      order_by: [desc: p.inserted_at],
      preload: [:comments, :user]
    )
    |> WcsStudio.Repo.all()
  end


  def count_posts() do
    from(ul in WcsStudio.Post,select: count())
    |> WcsStudio.Repo.one()
  end

  def get_post_by_id(id) do
    WcsStudio.Post
    |> where(id: ^id)
    |> preload(:user)
    |> preload(comments: [:user])
    |> WcsStudio.Repo.one()
  end


  def get_post_comments(post_id) do
    WcsStudio.Post
    |> where(id: ^post_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:comments)

  end

  def update_post(id, attrs) do
    case get_post_by_id(id) do
      nil -> {:error, :not_found}
      post ->
        post
        |> changeset(attrs)
        |> WcsStudio.Repo.update()
    end
  end


  def add(title, subject, body, tags, user_id) do
    %__MODULE__{}
    |> changeset(%{
      title: title,
      subject: subject,
      body: body,
      tags: tags,
      user_id: user_id
    })
    |> WcsStudio.Repo.insert()
  end


  def delete_post(post) do
    WcsStudio.Repo.delete(post)
  end

  def estimate_read_time(body) do
    word_count = body
                 |> String.split(~r/\s+/)
                 |> Enum.filter(&(&1 != ""))
                 |> length()

    minutes = max(1, round(word_count / 225))

    "#{minutes} min #{gettext("read")}"
  end

  def parse_tags(tags) do
    tags
    |> String.split(":")
    |> Enum.filter(&(&1 != ""))
  end


  defp changeset(post, params) do
    post
    |> cast(params , [:title, :subject, :body, :tags, :user_id])
    |> validate_required([:title, :subject, :body, :tags, :user_id])
    |> foreign_key_constraint(:user_id)
  end

end

