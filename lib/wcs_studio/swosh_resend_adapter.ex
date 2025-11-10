defmodule WcsStudio.SwooshResendAdapter do
  @moduledoc """
  Swoosh adapter for Resend email service
  """

  use Swoosh.Adapter

  @impl true
  def deliver(%Swoosh.Email{} = email, config) do
    api_key = config[:api_key] || raise "No API key configured for Resend"

    params = %{
      from: prepare_recipient(email.from),
      to: Enum.map(email.to, &prepare_recipient/1),
      subject: email.subject
    }

    # Add HTML body if present
    params = if email.html_body, do: Map.put(params, :html, email.html_body), else: params

    # Add text body if present
    params = if email.text_body, do: Map.put(params, :text, email.text_body), else: params

    # Add reply_to if present
    params = if email.reply_to, do: Map.put(params, :reply_to, Enum.map(email.reply_to, &prepare_recipient/1)), else: params

    # Add cc if present
    params = if email.cc && email.cc != [], do: Map.put(params, :cc, Enum.map(email.cc, &prepare_recipient/1)), else: params

    # Add bcc if present
    params = if email.bcc && email.bcc != [], do: Map.put(params, :bcc, Enum.map(email.bcc, &prepare_recipient/1)), else: params

    case Resend.Emails.send(params) do
      {:ok, result} -> {:ok, %{id: result["id"]}}
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def validate_config(config) do
    if config[:api_key] in [nil, ""] do
      raise ArgumentError, """
      expected [:api_key] to be set, got: #{inspect(config[:api_key])}
      """
    end

    config
  end

  @impl true
  def validate_dependency do
    Code.ensure_loaded?(Resend)
  end

  defp prepare_recipient({name, email}), do: "#{name} <#{email}>"
  defp prepare_recipient(email) when is_binary(email), do: email
end