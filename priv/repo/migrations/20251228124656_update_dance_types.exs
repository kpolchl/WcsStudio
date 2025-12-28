defmodule WcsStudio.Repo.Migrations.UpdateDanceTypes do
  use Ecto.Migration

  def change do
    alter table(:dance_types) do
      add :pic_url, :string
    end

  end
end
