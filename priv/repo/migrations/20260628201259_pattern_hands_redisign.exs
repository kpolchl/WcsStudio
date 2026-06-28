defmodule WcsStudio.Repo.Migrations.PatternHandsRedisign do
  use Ecto.Migration

  def change do
    alter table(:patterns) do
      remove :hands
      add :starting_hands, :string
      add :ending_hands, :string
    end

    create constraint(:patterns, :starting_hands_must_be_valid,
      check: "starting_hands IN ('left_left', 'left_right', 'right_right', 'right_left', 'both_hands')"
    )

    create constraint(:patterns, :ending_hands_must_be_valid,
      check: "ending_hands IN ('left_left', 'left_right', 'right_right', 'right_left', 'both_hands')"
    )
  end
end
