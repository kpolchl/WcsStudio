defmodule WcsStudio.UserLesson do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "user_lessons" do
    belongs_to :user, WcsStudio.Accounts.User
    belongs_to :lesson, WcsStudio.Lesson
    timestamps()
  end

  def get_user_lessons(user_id) do
    WcsStudio.UserLesson
    |> where(user_id: ^user_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:lesson)
  end

  def get_user_lesson(user_id, lesson_id) do
    __MODULE__
    |> where([u], u.user_id == ^user_id and u.lesson_id == ^lesson_id)
    |> WcsStudio.Repo.one()
  end

  def get_chart_data(user_id) do
    all_lessons = from(ul in WcsStudio.Lesson,
                    select: count()
                  ) |> WcsStudio.Repo.one()

    attended = from(ul in WcsStudio.UserLesson,
                 where: ul.user_id == ^user_id,
                 select: count()
               ) |> WcsStudio.Repo.one()

    [all_lessons, attended]
  end

  def add(user_id, lesson_id) do
    %__MODULE__{}
    |> changeset(%{user_id: user_id, lesson_id: lesson_id})
    |> WcsStudio.Repo.insert()
  end

  def delete(user_lesson) do
    WcsStudio.Repo.delete(user_lesson)
  end

  defp changeset(user_lesson, params \\ %{}) do
    user_lesson
    |> cast(params, [:user_id, :lesson_id])
    |> validate_required([:user_id, :lesson_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:lesson_id)
    |> unique_constraint([:user_id, :lesson_id], name: :user_lessons_user_id_lesson_id_index)
  end
end