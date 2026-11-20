defmodule WcsStudio.Repo.Migrations.AllowStartingPositionHands do
  use Ecto.Migration

  @hands ~w(left_left left_right right_right right_left both_hands starting_position)
  @legacy_hands ~w(left_left left_right right_right right_left both_hands)

  def up do
    drop_constraints()

    create constraint(:patterns, :starting_hands_must_be_valid,
             check: "starting_hands IN (#{sql_values(@hands)})"
           )

    create constraint(:patterns, :ending_hands_must_be_valid,
             check: "ending_hands IN (#{sql_values(@hands)})"
           )
  end

  def down do
    drop_constraints()

    create constraint(:patterns, :starting_hands_must_be_valid,
             check: "starting_hands IN (#{sql_values(@legacy_hands)})"
           )

    create constraint(:patterns, :ending_hands_must_be_valid,
             check: "ending_hands IN (#{sql_values(@legacy_hands)})"
           )
  end

  defp drop_constraints do
    drop constraint(:patterns, :starting_hands_must_be_valid)
    drop constraint(:patterns, :ending_hands_must_be_valid)
  end

  defp sql_values(values) do
    values |> Enum.map(&"'#{&1}'") |> Enum.join(", ")
  end
end
