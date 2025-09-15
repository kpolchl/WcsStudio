defmodule WcsStudio.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string
      add :level, :string
      add :datetime, :utc_datetime
      add :place, :string
      add :lesson_vid_url, :string
      add :instructor_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end
  end
end