defmodule WcsStudio.User do

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :role, :string, default: "user"
    field :course_enrolled, :boolean, default: false
    field :profile_pic, :string, default: "temp/user_icon.png"
    has_many :post, WcsStudio.Post
    has_many :comment , WcsStudio.Comment
    has_many :user_lesson , WcsStudio.UserLesson
    many_to_many :lessons, WcsStudio.Lesson, join_through: "lessons_instructors"
    has_many :user_pattern , WcsStudio.UserPattern
    timestamps()
  end


  def find_by_id(id) do
    WcsStudio.User
    |> where(id: ^id)
    |> WcsStudio.Repo.all()
  end

  def find_by_name(username) do
    WcsStudio.User
    |> where(username: ^username)
    |> WcsStudio.Repo.all()
  end

  def add(username, email, password, password_confirmation) do
    %WcsStudio.User{}
    |> changeset(%{username: username, email: email, password: password, password_confirmation: password_confirmation})
    |> WcsStudio.Repo.insert()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

  defp changeset(user, params \\ %{}) do
    user
    |> cast(params , [:username, :email, :password_hash, :password, :password_confirmation, :role, :course_enrolled, :profile_pic,])
    |> validate_required([:username, :email, :password, :password_confirmation ])
    |> validate_format(:email,  ~r/@/)
    |> unique_constraint([:username, :email])
    |> validate_confirmation(:password)
    |> hash_password()
  end

end