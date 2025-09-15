defmodule WcsStudio.Repo.Migrations.UpdateLessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      remove :datetime
    end

  end
end
