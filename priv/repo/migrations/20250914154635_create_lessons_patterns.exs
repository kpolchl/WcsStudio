defmodule WcsStudio.Repo.Migrations.CreateLessonsPattern do
  use Ecto.Migration

  def change do
    create table(:lesson_patterns) do
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :pattern_id, references(:patterns, on_delete: :delete_all), null: false

    end
  end
end