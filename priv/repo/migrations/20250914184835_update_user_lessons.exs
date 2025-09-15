defmodule WcsStudio.Repo.Migrations.UpdateUserLessons do
  use Ecto.Migration

  def change do
    alter table(:user_lessons) do
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
