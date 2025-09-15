defmodule WcsStudio.Repo.Migrations.UserLessons do
  use Ecto.Migration

  def change do
    create table(:user_lessons) do
      add :attended, :boolean
    end
  end
end