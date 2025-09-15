defmodule WcsStudio.Pattern do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "patterns" do
    field :name, :string
    field :description, :string
    field :video_url, :string
    belongs_to :dance_type, WcsStudio.DanceType
    has_many :user_patterns, WcsStudio.UserPattern
    many_to_many :lessons, WcsStudio.Pattern, join_through: "lesson_patterns"

    timestamps()
  end

  def get_all() do
    WcsStudio.Repo.all(WcsStudio.Pattern)
  end

  def add(dance_type_id, name, description, video_url \\ "test") do
    %__MODULE__{}
    |> changeset(%{dance_type_id: dance_type_id, name: name, description: description, video_url: video_url})
    |> WcsStudio.Repo.insert()
  end

  def update_pattern(dance_type, dance_type_id, name, description, video_url) do
    dance_type
    |> changeset(%{dance_type_id: dance_type_id, name: name, description: description, video_url: video_url})
    |> WcsStudio.Repo.update()
  end

  ## still not so simple
  def delete_pattern(pattern) do
    WcsStudio.Repo.delete(pattern)
  end

  defp changeset(pattern, attrs \\ %{}) do
    pattern
    |> cast(attrs, [:name, :description, :video_url, :dance_type_id])
    |> validate_required([:name, :description, :dance_type_id])
    |> foreign_key_constraint(:dance_type_id)
  end

end
