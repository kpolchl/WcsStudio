defmodule WcsStudio.Pattern do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "patterns" do
    field :name, :string
    field :general_description, :string
    field :leader_description, :string
    field :follower_description, :string
    field :video_url, :string
    belongs_to :dance_type, WcsStudio.DanceType
    has_many :user_patterns, WcsStudio.UserPattern
    many_to_many :lessons, WcsStudio.Pattern, join_through: "lesson_patterns"

    timestamps()
  end

  def get_all() do
    WcsStudio.Repo.all(WcsStudio.Pattern)
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(WcsStudio.Pattern, id)
  end

  def get_by_dance_type_id(dance_type_id) do
    WcsStudio.Pattern
    |> where(dance_type_id: ^dance_type_id)
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def get_by_id_name_or_general_description(dance_type_id, query_string) do
    from(p in WcsStudio.Pattern,
      where: p.dance_type_id == ^dance_type_id and (ilike(p.name, ^"%#{query_string}%") or ilike(p.general_description, ^"%#{query_string}%"))
    )
    |> WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(:dance_type)
  end

  def add(dance_type_id, name, general_description, leader_description, follower_description, video_url \\ "test") do
    %__MODULE__{}
    |> changeset(%{
      dance_type_id: dance_type_id,
      name: name,
      general_description: general_description,
      video_url: video_url,
      leader_description: leader_description,
      follower_description: follower_description
    })
    |> WcsStudio.Repo.insert()
  end

  def update(pattern, dance_type_id, name, general_description, leader_description, follower_description, video_url) do
    pattern
    |> changeset(%{
      dance_type_id: dance_type_id,
      name: name,
      general_description: general_description,
      video_url: video_url,
      leader_description: leader_description,
      follower_description: follower_description
    })
    |> WcsStudio.Repo.update()
  end

  def delete_pattern(id) do
    case get_by_id(id) do
      nil -> {:error, :not_found}
      pattern -> WcsStudio.Repo.delete(pattern)
    end
  end

  defp changeset(pattern, attrs \\ %{}) do
    pattern
    |> cast(attrs, [:name, :general_description, :leader_description, :follower_description, :video_url, :dance_type_id])
    |> validate_required([:name, :general_description, :dance_type_id])
    |> foreign_key_constraint(:dance_type_id)
  end
end
