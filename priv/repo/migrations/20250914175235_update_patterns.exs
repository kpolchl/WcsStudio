defmodule WcsStudio.Repo.Migrations.UpdatePatterns do
  use Ecto.Migration

  def change do
    alter table(:patterns) do
      add :dance_type_id, references(:dance_types, on_delete: :delete_all)
    end

  end
end
