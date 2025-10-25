defmodule WcsStudio.Repo.Migrations.UserPatternsFix do
  use Ecto.Migration

  def change do
    alter table(:user_patterns) do
      remove :pattern_id
      add :pattern_id, references(:patterns, on_delete: :delete_all)
    end
  end
end
