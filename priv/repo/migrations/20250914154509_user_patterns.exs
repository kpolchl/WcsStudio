defmodule WcsStudio.Repo.Migrations.UserPatterns do
  use Ecto.Migration

  def change do
    create table(:user_patterns) do
      add :status, :string
      add :user_id, references(:users ,on_delete: :delete_all)

      timestamps()
    end

  end
end