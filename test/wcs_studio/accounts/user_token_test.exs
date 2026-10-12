defmodule WcsStudio.Accounts.UserTokenTest do
  use WcsStudio.DataCase, async: true

  import WcsStudio.AccountsFixtures

  alias WcsStudio.Accounts.UserToken

  describe "build_session_token/1" do
    test "builds a session token struct" do
      user = user_fixture()

      assert {token, %UserToken{context: "session"} = user_token} =
               UserToken.build_session_token(user)

      assert is_binary(token)
      assert user_token.user_id == user.id
    end
  end

  describe "verify_session_token_query/1" do
    test "returns a query that resolves to the user" do
      user = user_fixture()
      {token, user_token} = UserToken.build_session_token(user)
      Repo.insert!(user_token)

      assert {:ok, query} = UserToken.verify_session_token_query(token)
      assert Repo.one(query).id == user.id
    end

    test "does not resolve expired tokens" do
      user = user_fixture()
      {token, user_token} = UserToken.build_session_token(user)
      Repo.insert!(user_token)
      Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert {:ok, query} = UserToken.verify_session_token_query(token)
      assert Repo.one(query) == nil
    end
  end

  describe "build_email_token/2 and verify_email_token_query/2" do
    test "round-trips a confirm token" do
      user = user_fixture()
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      assert {:ok, query} = UserToken.verify_email_token_query(encoded_token, "confirm")
      assert Repo.one(query).id == user.id
    end

    test "round-trips a reset password token" do
      user = user_fixture()
      {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
      Repo.insert!(user_token)

      assert {:ok, query} =
               UserToken.verify_email_token_query(encoded_token, "reset_password")

      assert Repo.one(query).id == user.id
    end

    test "returns :error for a malformed token" do
      assert UserToken.verify_email_token_query("not base64", "confirm") == :error
    end

    test "does not resolve a token issued for a changed email" do
      user = user_fixture()
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      Repo.update!(Ecto.Changeset.change(user, email: unique_user_email()))

      assert {:ok, query} = UserToken.verify_email_token_query(encoded_token, "confirm")
      assert Repo.one(query) == nil
    end
  end

  describe "verify_change_email_token_query/2" do
    test "round-trips a change email token" do
      user = user_fixture()
      {encoded_token, user_token} = UserToken.build_email_token(user, "change:old@example.com")
      inserted = Repo.insert!(user_token)

      assert {:ok, query} =
               UserToken.verify_change_email_token_query(
                 encoded_token,
                 "change:old@example.com"
               )

      assert Repo.get(query, inserted.id)
    end

    test "returns :error for a malformed token" do
      assert UserToken.verify_change_email_token_query("not base64", "change:old@example.com") ==
               :error
    end
  end

  describe "by_user_and_contexts_query/2" do
    test "returns all tokens for a user" do
      user = user_fixture()
      {_token, user_token} = UserToken.build_session_token(user)
      Repo.insert!(user_token)

      assert Enum.count(Repo.all(UserToken.by_user_and_contexts_query(user, :all))) == 1
    end

    test "filters tokens by context" do
      user = user_fixture()
      {_session, session_token} = UserToken.build_session_token(user)
      {_confirm, confirm_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(session_token)
      Repo.insert!(confirm_token)

      contexts = Repo.all(UserToken.by_user_and_contexts_query(user, ["confirm"]))
      assert Enum.map(contexts, & &1.context) == ["confirm"]
    end
  end

  describe "by_token_and_context_query/2" do
    test "builds a query matching token and context" do
      user = user_fixture()
      {token, user_token} = UserToken.build_session_token(user)
      inserted = Repo.insert!(user_token)

      query = UserToken.by_token_and_context_query(token, "session")
      assert Repo.one(query).id == inserted.id
    end
  end
end
