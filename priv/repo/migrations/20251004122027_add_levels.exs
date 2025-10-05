defmodule WcsStudio.Repo.Migrations.AddLevels do
  use Ecto.Migration

  def change do
    create table(:levels) do
      add :name, :string
      timestamps()
    end

    alter table(:lessons) do
      remove :level
      add :level_id, references(:levels, on_delete: :delete_all)
    end
  end
end
