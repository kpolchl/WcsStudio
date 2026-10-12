defmodule WcsStudio.Accounts.UserNotifierTest do
  use WcsStudio.DataCase, async: true

  import Swoosh.TestAssertions
  import WcsStudio.AccountsFixtures

  alias WcsStudio.Accounts.UserNotifier

  describe "deliver_confirmation_instructions/2" do
    test "sends a confirmation email" do
      user = user_fixture()

      assert {:ok, %Swoosh.Email{}} =
               UserNotifier.deliver_confirmation_instructions(
                 user,
                 "https://example.com/confirm/token"
               )

      assert_email_sent(fn email ->
        email.subject == "Confirmation instructions" &&
          email.text_body =~ "https://example.com/confirm/token"
      end)
    end
  end

  describe "deliver_reset_password_instructions/2" do
    test "sends a reset password email" do
      user = user_fixture()

      assert {:ok, %Swoosh.Email{}} =
               UserNotifier.deliver_reset_password_instructions(
                 user,
                 "https://example.com/reset/token"
               )

      assert_email_sent(fn email ->
        email.subject == "Reset password instructions" &&
          email.text_body =~ "https://example.com/reset/token"
      end)
    end
  end

  describe "deliver_update_email_instructions/2" do
    test "sends an update email email" do
      user = user_fixture()

      assert {:ok, %Swoosh.Email{}} =
               UserNotifier.deliver_update_email_instructions(
                 user,
                 "https://example.com/change/token"
               )

      assert_email_sent(fn email ->
        email.subject == "Update email instructions" &&
          email.text_body =~ "https://example.com/change/token"
      end)
    end
  end
end
