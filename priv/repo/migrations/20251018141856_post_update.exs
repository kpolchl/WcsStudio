defmodule WcsStudio.Repo.Migrations.PostUpdate do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :subject, :string
      add :tags, :string
    end
  end
end
