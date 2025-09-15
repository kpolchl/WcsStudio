defmodule WcsStudio.Repo.Migrations.Posts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :string
      add :user_id ,references(:users, on_delete: :delete_all)
      add :comment_id , references(:posts, on_delete: :delete_all)

      timestamps()
    end
  end
end