defmodule WcsStudio.Repo.Migrations.Relations do
  use Ecto.Migration

  def change do
    alter table(:user_patterns) do
      add :pattern_id, references(:patterns, on_delete: :nothing)
    end
  end
end
