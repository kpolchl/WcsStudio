# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WcsStudio.Repo.insert!(%WcsStudio.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WcsStudio.Pattern

# Every hand position in the graph gets used as both a source and a target.
# The cycle below is deterministic, so re-running the seed is a no-op.
nodes = [:left_left, :left_right, :right_right, :right_left, :both_hands, :starting_position]

# Patterns whose hands are meaningful for the dance step (and the few that
# already had hand values before seeding) keep those values instead.
hands_overrides = %{
  6 => {:left_right, :left_left},
  13 => {:right_right, :left_right},
  18 => {:both_hands, :left_right},
  26 => {:left_left, :right_right},
  29 => {:right_right, :right_right},
  30 => {:left_right, :both_hands},
  31 => {:both_hands, :left_right},
  32 => {:right_right, :left_right},
  33 => {:right_right, :right_right},
  34 => {:both_hands, :left_right},
  42 => {:right_right, :right_right},
  44 => {:left_right, :left_right},
  47 => {:left_left, :left_left},
  48 => {:left_left, :left_left}
}

# Patterns are danced over either 6 or 8 counts. Normalise any legacy values
# (9, 10, 12, ...) to the nearest of those two.
normalize_count = fn
  count when count in [6, 8] -> count
  count when is_integer(count) and count > 7 -> 8
  _ -> 6
end

Pattern.get_all()
|> Enum.sort_by(& &1.id)
|> Enum.with_index()
|> Enum.each(fn {pattern, index} ->
  default_hands = {
    Enum.at(nodes, rem(index + 1, length(nodes))),
    Enum.at(nodes, rem(index + 3, length(nodes)))
  }

  {starting_hands, ending_hands} = Map.get(hands_overrides, pattern.id, default_hands)

  attrs = %{
    starting_hands: starting_hands,
    ending_hands: ending_hands,
    count_num: normalize_count.(pattern.count_num)
  }

  changed? =
    attrs.starting_hands != pattern.starting_hands or
      attrs.ending_hands != pattern.ending_hands or
      attrs.count_num != pattern.count_num

  if changed? do
    case Pattern.update(pattern, attrs) do
      {:ok, updated} ->
        IO.puts(
          "Updated pattern #{updated.id} (#{updated.name}): " <>
            "#{updated.starting_hands} -> #{updated.ending_hands}, count #{updated.count_num}"
        )

      {:error, changeset} ->
        raise "Failed to update pattern #{pattern.id}: #{inspect(changeset.errors)}"
    end
  end
end)
