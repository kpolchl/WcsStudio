defmodule WcsStudio.UserPatternsFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.UserPattern` context.
  """

  import WcsStudio.AccountsFixtures
  import WcsStudio.PatternsFixtures

  def user_pattern_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()
    pattern = Map.get(attrs, :pattern) || pattern_fixture()

    {:ok, user_pattern} =
      WcsStudio.UserPattern.add(
        pattern.id,
        user.id,
        Map.get(attrs, :status, "in_progress")
      )

    user_pattern
  end
end
