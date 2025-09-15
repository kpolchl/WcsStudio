defmodule WcsStudio.DanceType do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "dance_types" do
    field :name, :string
    field :description, :string
    has_many :patterns, WcsStudio.Pattern
  end

  def get_all() do
    WcsStudio.Repo.all(WcsStudio.DanceType)
  end

  def get_by_id(id) do
    WcsStudio.Repo.get(WcsStudio.DanceType , id)
  end

  def update_dance_type(dance_type, new_name, new_description) do
    dance_type
    |> changeset(%{name: new_name, description: new_description})
    |> WcsStudio.Repo.update()
  end

  def add(name, description) do
    %__MODULE__{}
    |> changeset(%{name: name, description: description})
    |> WcsStudio.Repo.insert()
  end

  def delete_dance_type(dance_type) do
    WcsStudio.Repo.delete(dance_type)
  end

  defp changeset(dance_type, params \\ %{}) do
    dance_type
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end

end
