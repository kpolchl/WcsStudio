defmodule WcsStudio.Repo.Migrations.CreateLessonsInstructors do
  use Ecto.Migration

  def change do
    create table(:lessons_instructors) do
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :instructor_id, references(:users, on_delete: :delete_all)
    end

    create unique_index(:lessons_instructors, [:lesson_id, :instructor_id])
  end
end
