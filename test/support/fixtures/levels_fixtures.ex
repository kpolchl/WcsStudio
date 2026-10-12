defmodule WcsStudio.LevelsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.Levels` context.
  """

  def unique_level_name, do: "Level #{System.unique_integer([:positive])}"

  def level_fixture(attrs \\ %{}) do
    name = Map.get(attrs, :name, unique_level_name())

    {:ok, level} = WcsStudio.Levels.add(name)

    level
  end
end
