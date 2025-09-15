defmodule WcsStudio.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_hash, :string
      add :role, :string
      add :course_enrolled, :boolean
      add :profile_pic, :string

      timestamps()
    end
  end
end