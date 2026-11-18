defmodule WcsStudio.Repo.Migrations.AddPicUrlToDanceTypes do
  use Ecto.Migration

  def up do
    # Some databases still have the column from an older (since deleted)
    # migration, so only add it when it is actually missing.
    unless column_exists?() do
      alter table(:dance_types) do
        add :pic_url, :string
      end
    end

    # pic_url used to be a virtual field, so nothing was ever persisted and
    # the cards rendered images with an empty src. Backfill the known styles.
    execute """
    UPDATE dance_types SET pic_url = CASE name_en
      WHEN 'Cha-Cha' THEN '/images/Cha-cha.webp'
      WHEN 'Samba' THEN '/images/Samba.webp'
      WHEN 'Viennese Waltz' THEN '/images/Vienna-Valtz.webp'
      WHEN 'West Coast Swing' THEN '/images/West-coast-swing.webp'
    END
    WHERE name_en IN ('Cha-Cha', 'Samba', 'Viennese Waltz', 'West Coast Swing')
    """
  end

  def down do
    alter table(:dance_types) do
      remove :pic_url
    end
  end

  defp column_exists? do
    repo().query!(
      "SELECT 1 FROM information_schema.columns WHERE table_name = 'dance_types' AND column_name = 'pic_url'"
    ).num_rows > 0
  end
end
