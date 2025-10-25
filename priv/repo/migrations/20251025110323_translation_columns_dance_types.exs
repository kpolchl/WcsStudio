defmodule WcsStudio.Repo.Migrations.TranslationColumnsDanceTypes do
  use Ecto.Migration

  def change do
    alter table(:dance_types) do
      add :name_pl, :string
      add :description_pl, :string
      add :country_pl, :string
      add :tag_pl, :string

    end
    rename table(:dance_types), :name, to: :name_en
    rename table(:dance_types), :description, to: :description_en
    rename table(:dance_types), :country, to: :country_en
    rename table(:dance_types), :tag, to: :tag_en

  end
end
