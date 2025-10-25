defmodule WcsStudio.Repo.Migrations.UserLessonsAddTimestamps do
  use Ecto.Migration

  def change do
    alter table(:user_lessons) do
      timestamps()
    end


  end
end
