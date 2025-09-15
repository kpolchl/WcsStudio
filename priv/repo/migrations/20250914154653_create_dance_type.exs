defmodule WcsStudio.Repo.Migrations.CreateDanceType do
  use Ecto.Migration

  def change do
    create table(:dance_types) do
      add :name, :string
      add :description, :string
      add :dance_type_id, references(:patterns, on_delete: :delete_all)
    end
  end
end