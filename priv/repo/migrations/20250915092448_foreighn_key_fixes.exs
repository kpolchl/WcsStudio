defmodule WcsStudio.Repo.Migrations.ForeighnKeyFixes do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :comment_id
    end
    alter table(:patterns) do
      remove :pattern_id
    end
    alter table(:dance_types) do
      remove :dance_type_id
    end
  end
end
