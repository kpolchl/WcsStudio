defmodule WcsStudio.Repo.Migrations.ProfileQr do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :qr_code_url, :string
    end

  end
end
