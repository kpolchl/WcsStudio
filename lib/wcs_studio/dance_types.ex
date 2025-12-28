defmodule WcsStudio.DanceType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "dance_types" do
    field :name_en, :string
    field :description_en, :string
    field :country_en, :string
    field :tag_en, :string
    field :name_pl, :string
    field :description_pl, :string
    field :country_pl, :string
    field :tag_pl, :string
    field :type, :string
    field :pic_url, :string

    has_many :patterns, WcsStudio.Pattern
    has_many :lessons, WcsStudio.Lesson
    timestamps()
  end

  def get_all() do
    WcsStudio.Repo.all(WcsStudio.DanceType)
  end

  def get_by_type(type) do
    WcsStudio.DanceType
    |> where(type: ^type)
    |> WcsStudio.Repo.all()
  end

  def get_first do
    from(dt in WcsStudio.DanceType,
      limit: 1
    )
    |> WcsStudio.Repo.one()
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(WcsStudio.DanceType, id)
  end

  # Updated to accept attrs map with localized fields
  def update_dance_type(dance_type, attrs) do
    dance_type
    |> changeset(attrs)
    |> WcsStudio.Repo.update()
  end

  # Updated to accept attrs map with localized fields
  def add(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> WcsStudio.Repo.insert()
  end

  def delete_dance_type(dance_type) do
    WcsStudio.Repo.delete(dance_type)
  end

  # Helper functions to get localized content
  def get_name(dance_type, locale) do
    case locale do
      "pl" -> dance_type.name_pl || dance_type.name_en
      "en" -> dance_type.name_en
      _ -> dance_type.name_en
    end
  end

  def get_description(dance_type, locale) do
    case locale do
      "pl" -> dance_type.description_pl || dance_type.description_en
      "en" -> dance_type.description_en
      _ -> dance_type.description_en
    end
  end

  def get_country(dance_type, locale) do
    case locale do
      "pl" -> dance_type.country_pl || dance_type.country_en
      "en" -> dance_type.country_en
      _ -> dance_type.country_en
    end
  end

  def get_tag(dance_type, locale) do
    case locale do
      "pl" -> dance_type.tag_pl || dance_type.tag_en
      "en" -> dance_type.tag_en
      _ -> dance_type.tag_en
    end
  end

  defp changeset(dance_type, params) do
    dance_type
    |> cast(params, [
      :name_en,
      :name_pl,
      :description_en,
      :description_pl,
      :country_en,
      :country_pl,
      :tag_en,
      :tag_pl,
      :type,
      :pic_url
    ])
    |> validate_required([:type])
    |> validate_at_least_one_name()
    |> validate_at_least_one_description()
  end

  # Ensure at least one language has a name
  defp validate_at_least_one_name(changeset) do
    name_en = get_field(changeset, :name_en)
    name_pl = get_field(changeset, :name_pl)

    if is_nil(name_en) and is_nil(name_pl) do
      add_error(changeset, :name_en, "at least one language name is required")
    else
      changeset
    end
  end

  # Ensure at least one language has a description
  defp validate_at_least_one_description(changeset) do
    desc_en = get_field(changeset, :description_en)
    desc_pl = get_field(changeset, :description_pl)

    if is_nil(desc_en) and is_nil(desc_pl) do
      add_error(changeset, :description_en, "at least one language description is required")
    else
      changeset
    end
  end
end