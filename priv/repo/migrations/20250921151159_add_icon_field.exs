defmodule WcsStudio.Repo.Migrations.AddIconField do
  use Ecto.Migration

  def change do
    alter table(:dance_types) do
      add :icon_url, :string
    end


  end
end
