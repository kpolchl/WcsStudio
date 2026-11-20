defmodule WcsStudio.Graph do
  @moduledoc """
  Builds the Cytoscape payload for the pattern graph and generates practice flows.

  * node = a hand position (starting/ending hands)
  * edge = a pattern, going from its starting_hands to its ending_hands
  * edge label = pattern name, edge weight = count_num (number of steps)

  Every public function takes a `dance_type_id`; pass `nil` to use all patterns.
  """
  import Ecto.Query
  alias WcsStudio.{Pattern, Repo}

  @hands [:left_left, :left_right, :right_right, :right_left, :both_hands, :starting_position]
  @practice_target 24

  def graph_data(dance_type_id \\ nil) do
    nodes =
      Enum.map(@hands, fn h ->
        %{data: %{id: to_string(h), label: node_label(h)}}
      end)

    edges =
      Enum.map(connectable_patterns(dance_type_id), fn p ->
        %{
          data: %{
            id: edge_id(p),
            pattern_id: p.id,
            source: to_string(p.starting_hands),
            target: to_string(p.ending_hands),
            label: p.name,
            weight: p.count_num || 0
          }
        }
      end)

    %{nodes: nodes, edges: edges}
  end

  @doc """
  Returns a list of patterns forming a walk through the graph
  (each pattern starts where the previous one ended) whose counts sum to `target`.
  Returns `[]` if no such walk exists.
  """
  def practice_sequence(dance_type_id, target \\ @practice_target) do
    patterns =
      dance_type_id
      |> connectable_patterns()
      |> Enum.filter(&(is_integer(&1.count_num) and &1.count_num > 0))

    by_start = Enum.group_by(patterns, & &1.starting_hands)

    starts =
      patterns
      |> Enum.map(& &1.starting_hands)
      |> Enum.uniq()
      |> Enum.shuffle()

    # `failed` memoises dead-end {hand, remaining} states, so the search stays cheap
    {result, _failed} =
      Enum.reduce_while(starts, {[], MapSet.new()}, fn hand, {_, failed} ->
        case search(hand, target, nil, by_start, failed) do
          {:ok, seq, failed} -> {:halt, {seq, failed}}
          {:fail, failed} -> {:cont, {[], failed}}
        end
      end)

    result
  end

  def edge_id(%Pattern{id: id}), do: "p#{id}"

  # -- Search ------------------------------------------------------------------

  defp search(_hand, 0, _prev, _by_start, failed), do: {:ok, [], failed}

  defp search(hand, remaining, prev_id, by_start, failed) do
    if MapSet.member?(failed, {hand, remaining}) do
      {:fail, failed}
    else
      candidates =
        by_start
        |> Map.get(hand, [])
        |> Enum.filter(&(&1.count_num <= remaining))
        |> Enum.shuffle()
        # stable sort: avoid repeating the previous pattern unless nothing else fits
        |> Enum.sort_by(&(&1.id == prev_id))

      case search_candidates(candidates, remaining, by_start, failed) do
        {:ok, _, _} = ok -> ok
        {:fail, failed} -> {:fail, MapSet.put(failed, {hand, remaining})}
      end
    end
  end

  defp search_candidates(candidates, remaining, by_start, failed) do
    Enum.reduce_while(candidates, {:fail, failed}, fn p, {:fail, failed} ->
      case search(p.ending_hands, remaining - p.count_num, p.id, by_start, failed) do
        {:ok, rest, failed} -> {:halt, {:ok, [p | rest], failed}}
        {:fail, failed} -> {:cont, {:fail, failed}}
      end
    end)
  end

  # -- Helpers -----------------------------------------------------------------

  defp connectable_patterns(dance_type_id) do
    from(p in Pattern,
      where: not is_nil(p.starting_hands) and not is_nil(p.ending_hands),
      order_by: [asc: p.name]
    )
    |> maybe_filter_dance_type(dance_type_id)
    |> Repo.all()
  end

  defp maybe_filter_dance_type(query, nil), do: query
  defp maybe_filter_dance_type(query, id), do: where(query, [p], p.dance_type_id == ^id)

  defp node_label(:both_hands), do: "Both hands"
  defp node_label(:starting_position), do: "Starting position"
  defp node_label(h), do: Pattern.hands_label(h)
end
