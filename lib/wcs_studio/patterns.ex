defmodule WcsStudio.Pattern do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "patterns" do
    field :name, :string
    field :general_description_en, :string
    field :leader_description_en, :string
    field :follower_description_en, :string
    field :general_description_pl, :string
    field :leader_description_pl, :string
    field :follower_description_pl, :string
    field :video_url, :string
    belongs_to :dance_type, WcsStudio.DanceType
    has_many :user_patterns, WcsStudio.UserPattern
    many_to_many :lessons, WcsStudio.Lesson, join_through: "lesson_patterns"

    timestamps()
  end

  def get_all() do
    WcsStudio.Repo.all(WcsStudio.Pattern)
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def count_patterns() do
    from(p in WcsStudio.Pattern, select: count())
    |> WcsStudio.Repo.one()
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(WcsStudio.Pattern, id)
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_by_dance_type_id(dance_type_id) do
    WcsStudio.Pattern
    |> where(dance_type_id: ^dance_type_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  # Updated to search in both locales
  def get_by_id_name_or_general_description(dance_type_id, query_string) do
    search_pattern = "%#{query_string}%"

    from(p in WcsStudio.Pattern,
      where: p.dance_type_id == ^dance_type_id and (
        ilike(p.name, ^search_pattern) or
        ilike(p.general_description_en, ^search_pattern) or
        ilike(p.general_description_pl, ^search_pattern)
        )
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  # Updated add function with localized fields
  def add(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> WcsStudio.Repo.insert()
  end

  # Updated update function with localized fields
  def update(pattern, attrs) do
    pattern
    |> changeset(attrs)
    |> WcsStudio.Repo.update()
  end

  def delete_pattern(id) do
    case get_by_id(id) do
      nil -> {:error, :not_found}
      pattern -> WcsStudio.Repo.delete(pattern)
    end
  end

  # Helper function to get description based on locale
  def get_general_description(pattern, locale) do
    case locale do
      "pl" -> pattern.general_description_pl
      "en" -> pattern.general_description_en
      _ -> pattern.general_description_en
    end
  end

  def get_leader_description(pattern, locale) do
    case locale do
      "pl" -> pattern.leader_description_pl
      "en" -> pattern.leader_description_en
      _ -> pattern.leader_description_en
    end
  end

  def get_follower_description(pattern, locale) do
    case locale do
      "pl" -> pattern.follower_description_pl
      "en" -> pattern.follower_description_en
      _ -> pattern.follower_description_en
    end
  end

  defp changeset(pattern, attrs \\ %{}) do
    pattern
    |> cast(attrs, [
      :name,
      :general_description_en,
      :general_description_pl,
      :leader_description_en,
      :leader_description_pl,
      :follower_description_en,
      :follower_description_pl,
      :video_url,
      :dance_type_id
    ])
    |> validate_required([:name, :dance_type_id])
    |> validate_at_least_one_description()
    |> foreign_key_constraint(:dance_type_id)
  end

  # Custom validation to ensure at least one language has descriptions
  defp validate_at_least_one_description(changeset) do
    general_en = get_field(changeset, :general_description_en)
    general_pl = get_field(changeset, :general_description_pl)

    if is_nil(general_en) and is_nil(general_pl) do
      add_error(changeset, :general_description_en, "at least one language description is required")
    else
      changeset
    end
  end
end