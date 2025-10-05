defmodule WcsStudio.Repo.Migrations.Datatypeupdate do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      modify :body, :text
    end

    alter table(:comments) do
      modify :body, :text
    end

    alter table(:patterns) do
      modify :description, :text
    end
    alter table(:lessons) do
      add :description, :text
    end
    alter table(:dance_types) do
      modify :description, :text
    end


  end
end
