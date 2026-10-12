defmodule WcsStudio.PatternsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.Pattern` context.
  """

  import WcsStudio.DanceTypesFixtures

  def unique_pattern_name, do: "Pattern #{System.unique_integer([:positive])}"

  @doc """
  Builds a changeset/map of valid pattern attributes.

  Pass `:dance_type` to attach the pattern to an existing dance type,
  otherwise a new dance type is created.
  """
  def pattern_attributes(attrs \\ %{}) do
    {dance_type, attrs} = Map.pop(attrs, :dance_type, nil)
    dance_type = dance_type || dance_type_fixture()

    attrs
    |> Enum.into(%{
      name: unique_pattern_name(),
      dance_type_id: dance_type.id,
      starting_hands: :left_left,
      ending_hands: :right_right,
      count_num: 6,
      video_url: "https://www.youtube.com/embed/abcdef"
    })
  end

  def pattern_fixture(attrs \\ %{}) do
    {:ok, pattern} =
      attrs
      |> pattern_attributes()
      |> WcsStudio.Pattern.add()

    pattern
  end
end
