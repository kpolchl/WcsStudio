defmodule WcsStudio.MailerTest do
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  alias WcsStudio.Mailer

  test "delivers an email through the configured test adapter" do
    email =
      Swoosh.Email.new(
        from: {"WcsStudio", "noreply@example.com"},
        to: {"Recipient", "recipient@example.com"},
        subject: "Hello",
        text_body: "hi"
      )

    assert {:ok, _metadata} = Mailer.deliver(email)
    assert_email_sent(subject: "Hello")
  end
end
