defmodule WcsStudio.Lesson do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "lessons" do
    field :title, :string
    field :level, :string
    field :place , :string
    field :lesson_vid_url, :string

    many_to_many :instructors, WcsStudio.User, join_through: "lessons_instructors", join_keys: [lesson_id: :id, instructor_id: :id]
    many_to_many :patterns, WcsStudio.Pattern , join_through: "lesson_patterns", join_keys: [lesson_id: :id ,pattern_id: :id]
    has_many :user_lessons, WcsStudio.UserPattern

    timestamps()
  end

  def add(title, instructor_ids, pattern_ids, level, place, lesson_vid_url) when is_list(instructor_ids) do
    instructors = WcsStudio.Repo.all(from u in WcsStudio.User, where: u.id in ^instructor_ids)
    patterns = WcsStudio.Repo.all(from p in WcsStudio.Pattern, where: p.id in ^pattern_ids)

    %__MODULE__{}
    |> changeset(%{title: title, level: level, place: place, lesson_vid_url: lesson_vid_url})
    |> put_assoc(:instructors, instructors)
    |> put_assoc(:patterns, patterns)
    |> WcsStudio.Repo.insert()
  end

  defp changeset(lesson, params \\ %{}) do
    lesson
    |> cast(params, [:title, :level, :place, :lesson_vid_url])
    |> validate_required([:title, :level, :place, :lesson_vid_url])
  end

  # update it it is not so simple
  def delete_lesson(lesson) do
    WcsStudio.Repo.delete(lesson)
  end

  defp validate_instructors() do
  end

end
