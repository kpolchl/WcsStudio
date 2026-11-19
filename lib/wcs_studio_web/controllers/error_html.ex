defmodule WcsStudioWeb.ErrorHTML do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on HTML requests.

  See config/config.exs.
  """
  use WcsStudioWeb, :html

  # Styled error pages share the same baseline card/button tokens as the
  # rest of the app (see docs/design-system.md). The root layout supplies
  # the stylesheet and dark page background.
  embed_templates "error_html/*"

  # Fallback for statuses without a dedicated template.
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
