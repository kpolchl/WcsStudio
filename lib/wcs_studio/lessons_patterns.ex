defmodule WcsStudio.LessonsPattern do
  @moduledoc false
  use Ecto.Schema

  schema "lesson_patterns" do
    belongs_to :patterns, WcsStudio.Pattern
    belongs_to :lessons, WcsStudio.Lesson
    timestamps()
  end
end
