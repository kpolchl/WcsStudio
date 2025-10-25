defmodule WcsStudio.Repo.Migrations.SimpleTranslation do
  use Ecto.Migration

  def change do
    alter table(:patterns) do
      add :general_description_pl, :text
      add :leader_description_pl, :text
      add :follower_description_pl, :text

    end
    rename table(:patterns), :general_description, to: :general_description_en
    rename table(:patterns), :leader_description, to: :leader_description_en
    rename table(:patterns), :follower_description, to: :follower_description_en


  end
end
