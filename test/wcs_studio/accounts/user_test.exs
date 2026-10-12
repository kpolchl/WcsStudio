defmodule WcsStudio.Accounts.UserTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures

  alias WcsStudio.Accounts.User

  describe "get_instructors/0" do
    test "returns only users with the instructor role" do
      instructor =
        user_fixture()
        |> Ecto.Changeset.change(role: "instructor")
        |> Repo.update!()

      _student = user_fixture()

      assert Enum.map(User.get_instructors(), & &1.id) == [instructor.id]
    end
  end

  describe "registration_changeset/3" do
    test "is valid with an email and password" do
      changeset = User.registration_changeset(%User{}, valid_user_attributes())
      assert changeset.valid?
    end

    test "hashes the password by default" do
      changeset = User.registration_changeset(%User{}, valid_user_attributes())
      assert changeset.changes.hashed_password
      refute Map.has_key?(changeset.changes, :password)
    end

    test "keeps the password when hashing is disabled" do
      changeset =
        User.registration_changeset(%User{}, valid_user_attributes(), hash_password: false)

      assert changeset.changes.password
      refute Map.has_key?(changeset.changes, :hashed_password)
    end

    test "requires an email and password" do
      changeset = User.registration_changeset(%User{}, %{})

      assert %{
               email: ["can't be blank"],
               password: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  describe "email_changeset/3" do
    test "requires the email to change" do
      user = user_fixture()

      assert %{email: ["did not change"]} = errors_on(User.email_changeset(user, %{}))
    end

    test "accepts a new valid email" do
      user = user_fixture()
      changeset = User.email_changeset(user, %{email: unique_user_email()})
      assert changeset.valid?
    end
  end

  describe "password_changeset/3" do
    test "validates the password confirmation" do
      changeset =
        User.password_changeset(%User{}, %{
          password: "a valid password",
          password_confirmation: "a different one"
        })

      assert %{password_confirmation: ["does not match password"]} = errors_on(changeset)
    end
  end

  describe "confirm_changeset/1" do
    test "sets confirmed_at" do
      changeset = User.confirm_changeset(%User{})
      assert changeset.changes.confirmed_at
    end
  end

  describe "valid_password?/2" do
    test "returns true for the correct password" do
      user = user_fixture()
      assert User.valid_password?(user, valid_user_password())
    end

    test "returns false for an incorrect password" do
      user = user_fixture()
      refute User.valid_password?(user, "wrong password")
    end

    test "returns false when the user has no hashed password" do
      refute User.valid_password?(%User{}, "anything")
    end

    test "returns false for a nil user" do
      refute User.valid_password?(nil, "anything")
    end
  end

  describe "validate_current_password/2" do
    test "leaves the changeset untouched for a valid password" do
      user = user_fixture()

      changeset =
        User.validate_current_password(Ecto.Changeset.change(user), valid_user_password())

      refute changeset.errors[:current_password]
    end

    test "adds an error for an invalid password" do
      user = user_fixture()
      changeset = User.validate_current_password(Ecto.Changeset.change(user), "invalid")

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end
  end

  describe "profile_pic_changeset/2" do
    test "casts the profile pic url" do
      changeset = User.profile_pic_changeset(%User{}, %{profile_pic_url: "/images/a.png"})
      assert Ecto.Changeset.get_change(changeset, :profile_pic_url) == "/images/a.png"
    end
  end
end
