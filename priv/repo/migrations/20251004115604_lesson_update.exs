defmodule WcsStudio.Repo.Migrations.LessonUpdate do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :dance_type_id, references(:dance_types, on_delete: :delete_all)
      add :date, :date
    end

  end
end
