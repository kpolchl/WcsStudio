defmodule WcsStudio.Levels do
  use Ecto.Schema
  import Ecto.Changeset

  schema "levels" do
    field :name, :string
    has_many :lessons, WcsStudio.Lesson, foreign_key: :level_id
    timestamps()
  end

  def get_all() do
    WcsStudio.Levels
    |> WcsStudio.Repo.all()
  end

  def add(name) do
    %__MODULE__{}
    |> changeset(%{name: name})
    |> WcsStudio.Repo.insert()
  end

  defp changeset(%__MODULE__{} = level, attrs) do
    level
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
