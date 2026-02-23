defmodule WcsStudio.Lesson do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "lessons" do
    field :title, :string
    field :place, :string
    field :lesson_vid_url, :string
    field :date, :date

    many_to_many :instructors, WcsStudio.Accounts.User,
      join_through: "lessons_instructors",
      join_keys: [lesson_id: :id, instructor_id: :id],
      on_replace: :delete

    many_to_many :patterns, WcsStudio.Pattern,
      join_through: "lesson_patterns",
      join_keys: [lesson_id: :id, pattern_id: :id],
      on_replace: :delete

    has_many :user_lessons, WcsStudio.UserPattern
    belongs_to :dance_type, WcsStudio.DanceType
    belongs_to :level, WcsStudio.Levels, foreign_key: :level_id

    timestamps()
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(WcsStudio.Lesson, id)
    |> WcsStudio.Repo.preload([:patterns, :instructors, :dance_type, :level])
  end

  def get_all() do
    WcsStudio.Lesson
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload([:patterns, :instructors, :dance_type, :level])
  end

  def get_first do
    from(p in WcsStudio.Lesson,
      limit: 1
    )
    |> WcsStudio.Repo.one() || %{dance_type_id: 1, level_id: 1}
  end

  def count_lessons do
    from(ul in WcsStudio.Lesson, select: count())
    |> WcsStudio.Repo.one()
  end

  def get_by_dance_type_and_level(dance_type_id, level_id) do
    WcsStudio.Lesson
    |> where([l], l.dance_type_id == ^dance_type_id and l.level_id == ^level_id)
    |> order_by(asc: :date)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload([:patterns, :instructors, :dance_type, :level])
  end

  def get_by_level_id(lessons, level_id) do
    Enum.filter(lessons, fn lesson -> lesson.level_id == level_id end)
  end

  def add(
        title,
        instructor_ids,
        pattern_ids,
        level_id,
        place,
        lesson_vid_url,
        date,
        dance_type_id
      ) do
    instructors =
      WcsStudio.Repo.all(from u in WcsStudio.Accounts.User, where: u.id in ^instructor_ids)

    patterns = WcsStudio.Repo.all(from p in WcsStudio.Pattern, where: p.id in ^pattern_ids)

    %__MODULE__{}
    |> changeset(%{
      title: title,
      level_id: level_id,
      place: place,
      lesson_vid_url: lesson_vid_url,
      date: date,
      dance_type_id: dance_type_id
    })
    |> put_assoc(:instructors, instructors)
    |> put_assoc(:patterns, patterns)
    |> WcsStudio.Repo.insert()
  end

  defp changeset(lesson, params) do
    lesson
    |> cast(params, [:title, :level_id, :place, :lesson_vid_url, :date, :dance_type_id])
    |> validate_required([:title, :level_id, :place, :date, :dance_type_id])
  end

  def update(
        lesson,
        title,
        instructor_ids,
        pattern_ids,
        level_id,
        place,
        lesson_vid_url,
        date,
        dance_type_id
      ) do
    # Convert string IDs to integers if needed
    instructor_ids =
      Enum.map(instructor_ids, fn id ->
        if is_binary(id), do: String.to_integer(id), else: id
      end)

    pattern_ids =
      Enum.map(pattern_ids, fn id ->
        if is_binary(id), do: String.to_integer(id), else: id
      end)

    instructors =
      WcsStudio.Repo.all(from u in WcsStudio.Accounts.User, where: u.id in ^instructor_ids)

    patterns = WcsStudio.Repo.all(from p in WcsStudio.Pattern, where: p.id in ^pattern_ids)

    # Use the EXISTING lesson struct, not a new one
    lesson
    |> changeset(%{
      title: title,
      level_id: level_id,
      place: place,
      lesson_vid_url: lesson_vid_url,
      date: date,
      dance_type_id: dance_type_id
    })
    |> put_assoc(:instructors, instructors)
    |> put_assoc(:patterns, patterns)
    |> WcsStudio.Repo.update()
  end

  def delete_lesson(id) do
    case get_by_id(id) do
      nil -> {:error, :not_found}
      lesson -> WcsStudio.Repo.delete(lesson)
    end
  end
end
