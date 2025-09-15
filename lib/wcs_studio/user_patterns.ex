defmodule WcsStudio.UserPattern do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "user_patterns" do
    field :status, :string
    belongs_to :user, WcsStudio.User
    belongs_to :pattern , WcsStudio.Pattern
    timestamps()
  end

  def add(pattern_id, user_id, status) do
    %__MODULE__{}
    |> changeset(%{pattern_id: pattern_id, user_id: user_id, status: status})
    |> WcsStudio.Repo.insert()
  end

#  def update_pattern()

  def get_user_patterns(user_id) do
    WcsStudio.UserPattern
    |> where(user_id: ^user_id)
    |>WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(pattern: [:dance_type])
  end

  defp changeset(pattern, attrs \\ %{}) do
    pattern
    |> cast(attrs, [:pattern_id, :user_id, :status])
    |> validate_required([:pattern_id, :user_id, :status])
    |> foreign_key_constraint(:pattern_id)
    |> foreign_key_constraint(:user_id)
  end
end
