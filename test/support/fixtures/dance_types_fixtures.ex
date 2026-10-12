defmodule WcsStudio.DanceTypesFixtures do
  @moduledoc """
  Test helpers for creating entities via the `WcsStudio.DanceType` context.
  """

  def unique_dance_type_name_en, do: "Dance #{System.unique_integer([:positive])}"
  def unique_dance_type_name_pl, do: "Taniec #{System.unique_integer([:positive])}"

  def valid_dance_type_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name_en: unique_dance_type_name_en(),
      name_pl: unique_dance_type_name_pl(),
      description_en: "An energetic partner dance.",
      description_pl: "Energiczny taniec partnerski.",
      country_en: "United States",
      country_pl: "Stany Zjednoczone",
      tag_en: "swing",
      tag_pl: "swing",
      type: "swing"
    })
  end

  def dance_type_fixture(attrs \\ %{}) do
    {:ok, dance_type} =
      attrs
      |> valid_dance_type_attributes()
      |> WcsStudio.DanceType.add()

    dance_type
  end
end
