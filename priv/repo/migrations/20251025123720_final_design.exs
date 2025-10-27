defmodule WcsStudio.Repo.Migrations.FinalDesign do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    # Users table
    create table(:users) do
      add :username, :string
      add :email, :citext, null: false
      add :role, :string, null: false, default: "student"
      add :course_enrolled, :boolean, default: false
      add :profile_pic_url, :string
      add :qr_code_url, :string
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:username])

    # Users tokens table
    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    # Levels table (created early since it's referenced by lessons)
    create table(:levels) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:levels, [:name])

    # Dance types table (created early since it's referenced by patterns and lessons)
    create table(:dance_types) do
      add :name_pl, :string, null: false
      add :description_pl, :text
      add :country_pl, :string
      add :tag_pl, :string
      add :name_en, :string, null: false
      add :description_en, :text
      add :country_en, :string
      add :tag_en, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:dance_types, [:name_en])
    create index(:dance_types, [:type])

    # Posts table
    create table(:posts) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :subject, :string
      add :tags, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:posts, [:subject])

    # Comments table
    create table(:comments) do
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :post_id, references(:posts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:comments, [:user_id])
    create index(:comments, [:post_id])

    # Patterns table
    create table(:patterns) do
      add :name, :string, null: false
      add :general_description_en, :text
      add :leader_description_en, :text
      add :follower_description_en, :text
      add :general_description_pl, :text
      add :leader_description_pl, :text
      add :follower_description_pl, :text
      add :video_url, :string
      add :dance_type_id, references(:dance_types, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:patterns, [:dance_type_id])
    create index(:patterns, [:name])

    # User patterns table
    create table(:user_patterns) do
      add :status, :string, null: false, default: "learning"
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :pattern_id, references(:patterns, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_patterns, [:user_id])
    create index(:user_patterns, [:pattern_id])
    create unique_index(:user_patterns, [:user_id, :pattern_id])

    # Lessons table
    create table(:lessons) do
      add :dance_type_id, references(:dance_types, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :place, :string
      add :level_id, references(:levels, on_delete: :delete_all), null: false
      add :lesson_vid_url, :string
      add :date, :date, null: false

      timestamps()
    end

    create index(:lessons, [:level_id])
    create index(:lessons, [:dance_type_id])
    create index(:lessons, [:date])

    # Lesson patterns junction table
    create table(:lesson_patterns) do
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :pattern_id, references(:patterns, on_delete: :delete_all), null: false
    end

    create index(:lesson_patterns, [:lesson_id])
    create index(:lesson_patterns, [:pattern_id])
    create unique_index(:lesson_patterns, [:lesson_id, :pattern_id])

    # User lessons junction table
    create table(:user_lessons) do
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_lessons, [:user_id])
    create index(:user_lessons, [:lesson_id])
    create unique_index(:user_lessons, [:user_id, :lesson_id])

    # Lessons instructors junction table
    create table(:lessons_instructors) do
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :instructor_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:lessons_instructors, [:instructor_id])
    create unique_index(:lessons_instructors, [:lesson_id, :instructor_id])
  end
end