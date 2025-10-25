defmodule WcsStudio.Repo.Migrations.DanceTypeUpdate do
  use Ecto.Migration

  def change do
    alter table(:dance_types) do
      add :country, :string
      add :tag, :string
      add :type, :string
    end

  end
end
