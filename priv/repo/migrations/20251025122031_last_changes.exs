defmodule WcsStudio.Repo.Migrations.LastChanges do
  use Ecto.Migration

  def change do
    alter table(:dance_types) do
      remove :icon_url
    end
    alter table (:user_lessons) do
      remove :attended
    end

  end
end
