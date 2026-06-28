defmodule WcsStudio.Repo.Migrations.PatternsRebuild do
  use Ecto.Migration

  @valid_values ~w(left_left left_right right_right right_left both_hands)

  def change do
    alter table(:patterns) do
      remove :count_description
      remove :leader_description_en
      remove :follower_description_en
      remove :leader_description_pl
      remove :follower_description_pl
      add :parent_id, references(:patterns, on_delete: :nilify_all)
    end

    execute(
      "UPDATE patterns SET hands = NULL WHERE hands NOT IN ('left_left','left_right','right_right','right_left','both_hands')",
      "SELECT 1"
    )

    create index(:patterns, [:parent_id])

    create constraint(:patterns, :hands_must_be_valid,
             check: "hands IN ('left_left, left_right, right_right, right_left, both_hands')"
           )
  end
end
