defmodule WcsStudio.Repo.Migrations.PatternsRename do
  use Ecto.Migration

  def change do
    rename table(:patterns), :class, to: :hands

  end
end
