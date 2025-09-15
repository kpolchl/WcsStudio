defmodule WcsStudio.Repo.Migrations.GenPatterns do
  use Ecto.Migration

  def change do
    create table(:patterns) do
      add :name, :string
      add :description, :string
      add :video_url, :string
      add :pattern_id, references(:user_patterns, on_delete: :delete_all)

      timestamps()
    end
  end
end
