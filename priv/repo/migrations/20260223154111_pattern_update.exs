defmodule WcsStudio.Repo.Migrations.PatternUpdate do
  use Ecto.Migration

  def change do
    alter table(:patterns) do
      remove :general_description_en
      add :class, :string
      add :count_description, :string
      add :count_num, :integer
    end
    alter table(:patterns) do
      remove :general_description_pl
    end

  end
end
