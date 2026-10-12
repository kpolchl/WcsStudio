defmodule WcsStudio.DanceTypeTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.DanceTypesFixtures

  alias WcsStudio.DanceType

  describe "add/1" do
    test "creates a dance type with valid attributes" do
      attrs = valid_dance_type_attributes()

      assert {:ok, dance_type} = DanceType.add(attrs)
      assert dance_type.name_en == attrs.name_en
      assert dance_type.name_pl == attrs.name_pl
      assert dance_type.type == attrs.type
    end

    test "requires a type" do
      attrs = Map.delete(valid_dance_type_attributes(), :type)

      assert {:error, changeset} = DanceType.add(attrs)
      assert %{type: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires at least one name" do
      attrs =
        valid_dance_type_attributes(%{name_en: nil, name_pl: nil})

      assert {:error, changeset} = DanceType.add(attrs)
      assert %{name_en: ["at least one language name is required"]} = errors_on(changeset)
    end

    test "requires at least one description" do
      attrs =
        valid_dance_type_attributes(%{description_en: nil, description_pl: nil})

      assert {:error, changeset} = DanceType.add(attrs)

      assert %{description_en: ["at least one language description is required"]} =
               errors_on(changeset)
    end

    test "enforces the unique name_en constraint" do
      dance_type = dance_type_fixture()

      assert_raise Ecto.ConstraintError, fn ->
        DanceType.add(valid_dance_type_attributes(%{name_en: dance_type.name_en}))
      end
    end
  end

  describe "get_all/0 and get_by_type/1" do
    test "returns all dance types" do
      dance_type = dance_type_fixture()
      assert Enum.any?(DanceType.get_all(), &(&1.id == dance_type.id))
    end

    test "filters by type" do
      swing = dance_type_fixture(%{type: "swing"})
      latin = dance_type_fixture(%{type: "latin"})

      types = DanceType.get_by_type("swing")
      ids = Enum.map(types, & &1.id)

      assert swing.id in ids
      refute latin.id in ids
    end
  end

  describe "get_first/0 and get_by_id/1" do
    test "returns the first dance type" do
      dance_type = dance_type_fixture()
      assert DanceType.get_first().id == dance_type.id
    end

    test "returns nil when empty" do
      assert DanceType.get_first() == nil
    end

    test "returns a dance type by id" do
      dance_type = dance_type_fixture()
      assert DanceType.get_by_id(dance_type.id).id == dance_type.id
    end

    test "returns nil for an unknown id" do
      assert DanceType.get_by_id(-1) == nil
    end
  end

  describe "update_dance_type/2 and delete_dance_type/1" do
    test "updates attributes" do
      dance_type = dance_type_fixture()

      assert {:ok, updated} = DanceType.update_dance_type(dance_type, %{type: "latin"})
      assert updated.type == "latin"
    end

    test "deletes a dance type" do
      dance_type = dance_type_fixture()

      assert {:ok, _} = DanceType.delete_dance_type(dance_type)
      assert DanceType.get_by_id(dance_type.id) == nil
    end
  end

  describe "localized getters" do
    setup do
      %{
        dance_type: %DanceType{
          name_en: "English Name",
          name_pl: "Polska Nazwa",
          description_en: "English Description",
          description_pl: "Polski Opis",
          country_en: "England",
          country_pl: "Anglia",
          tag_en: "tag_en",
          tag_pl: "tag_pl"
        }
      }
    end

    test "returns Polish values when available", %{dance_type: dance_type} do
      assert DanceType.get_name(dance_type, "pl") == "Polska Nazwa"
      assert DanceType.get_description(dance_type, "pl") == "Polski Opis"
      assert DanceType.get_country(dance_type, "pl") == "Anglia"
      assert DanceType.get_tag(dance_type, "pl") == "tag_pl"
    end

    test "returns English values for the en locale", %{dance_type: dance_type} do
      assert DanceType.get_name(dance_type, "en") == "English Name"
      assert DanceType.get_description(dance_type, "en") == "English Description"
      assert DanceType.get_country(dance_type, "en") == "England"
      assert DanceType.get_tag(dance_type, "en") == "tag_en"
    end

    test "falls back to English for an unknown locale", %{dance_type: dance_type} do
      assert DanceType.get_name(dance_type, "de") == "English Name"
      assert DanceType.get_description(dance_type, "de") == "English Description"
    end

    test "falls back to English for pl when the Polish value is missing" do
      dance_type = %DanceType{name_en: "English Name", name_pl: nil}
      assert DanceType.get_name(dance_type, "pl") == "English Name"
    end
  end
end
