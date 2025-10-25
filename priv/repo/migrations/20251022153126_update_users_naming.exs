defmodule WcsStudio.Repo.Migrations.UpdateUsersNaming do
  use Ecto.Migration

  def change do
    rename table(:users), :profile_pic, to: :profile_pic_url

  end
end
