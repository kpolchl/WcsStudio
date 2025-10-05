defmodule WcsStudio.Repo.Migrations.LessonChange2 do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      remove :description
    end

  end
end
