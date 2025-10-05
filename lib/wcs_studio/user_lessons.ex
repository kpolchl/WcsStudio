defmodule WcsStudio.UserLesson do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "user_lessons" do
    field :attended, :boolean
    belongs_to :user, WcsStudio.Accounts.User
    belongs_to :lesson, WcsStudio.Lesson
  end

  def get_user_lessons(user_id) do
    WcsStudio.UserLesson
    |> where(user_id: ^user_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:lesson)
  end

  def add(user_id, lesson_id, attended \\ false) do
    %__MODULE__{}
    |> changeset(%{user_id: user_id, lesson_id: lesson_id, attended: attended})
    |> WcsStudio.Repo.insert()

  end
  defp changeset(user_lesson, params \\ %{}) do
    user_lesson
    |> cast(params, [:user_id, :lesson_id, :attended])
    |> validate_required([:user_id, :lesson_id, :attended])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:lesson_id)
  end
end
