defmodule WcsStudio.Repo.Migrations.PatternsUpdate do
  use Ecto.Migration

  def change do
    alter table(:patterns) do
      add :leader_description, :text
      add :follower_description, :text
    end
    rename table(:patterns), :description, to: :general_description


  end
end
