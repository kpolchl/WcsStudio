defmodule WcsStudio.Comment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    belongs_to :post, WcsStudio.Post
    belongs_to :user, WcsStudio.Accounts.User
    timestamps()
    end

  def add(body, user_id, post_id) do
    %__MODULE__{}
    |> changeset(%{body: body, user_id: user_id, post_id: post_id})
    |> WcsStudio.Repo.insert()
  end

  def delete_comment(comment) do
    WcsStudio.Repo.delete(comment)
  end

    defp changeset(comment, params) do
      comment
      |> cast(params, [:body, :user_id, :post_id])
      |> validate_required([:body, :user_id, :post_id])
      |> foreign_key_constraint(:user_id)
      |> foreign_key_constraint(:post_id)
    end

end
