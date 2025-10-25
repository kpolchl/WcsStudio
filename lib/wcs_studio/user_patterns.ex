defmodule WcsStudio.UserPattern do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "user_patterns" do
    field :status, :string
    belongs_to :user, WcsStudio.Accounts.User
    belongs_to :pattern , WcsStudio.Pattern
    timestamps()
  end

  def get_user_patterns(user_id) do
    WcsStudio.UserPattern
    |> where(user_id: ^user_id)
    |>WcsStudio.Repo.all()
    |> WcsStudio.Repo.preload(pattern: [:dance_type])
  end

  def get_user_pattern(user_id, pattern_id) do
    __MODULE__
    |> where([u], u.user_id == ^user_id and u.pattern_id == ^pattern_id)
    |> WcsStudio.Repo.one()
  end


  def get_chart_data(user_id) do
    all_lessons = from(ul in WcsStudio.Pattern,
                    select: count()
                  ) |> WcsStudio.Repo.one()

    in_progress = from(ul in WcsStudio.UserPattern,
                    where: ul.user_id == ^user_id and ul.status == "in_progress",
                    select: count(ul.id)
                  ) |> WcsStudio.Repo.one()

    learned = from(ul in WcsStudio.UserPattern,
                where: ul.user_id == ^user_id and ul.status == "learned",
                select: count(ul.id)
              ) |> WcsStudio.Repo.one()

    [all_lessons, in_progress, learned]
  end

  def update_status(user_pattern, pattern_id, user_id, status) do
    user_pattern
    |> changeset(%{pattern_id: pattern_id, user_id: user_id, status: status})
    |> WcsStudio.Repo.update()
  end

  def add(pattern_id, user_id, status) do
    %__MODULE__{}
    |> changeset(%{pattern_id: pattern_id, user_id: user_id, status: status})
    |> WcsStudio.Repo.insert()
  end

  defp changeset(pattern, attrs \\ %{}) do
    pattern
    |> cast(attrs, [:pattern_id, :user_id, :status])
    |> validate_required([:pattern_id, :user_id, :status])
    |> foreign_key_constraint(:pattern_id)
    |> foreign_key_constraint(:user_id)
  end
end
