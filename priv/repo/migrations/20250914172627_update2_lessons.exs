defmodule WcsStudio.Repo.Migrations.Update2Lessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      remove :instructor_id
    end

  end
end
