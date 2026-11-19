defmodule WcsStudioWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use WcsStudioWeb, :controller` and
  `use WcsStudioWeb, :live_view`.
  """
  use WcsStudioWeb, :html
  import WcsStudioWeb.Components.LocaleSwitcher
  embed_templates "layouts/*"

  @doc """
  Opens/closes the mobile menu in one JS command chain.

  Uses `toggle_class("hidden")` everywhere (never `JS.toggle`, which sets an inline
  `display` that class-based hiding cannot undo) and locks body scroll while open so
  the page underneath no longer scrolls.
  """
  def toggle_mobile_menu do
    JS.toggle_class("hidden", to: "#mobile-menu")
    |> JS.toggle_class("hidden", to: "#mobile-menu-backdrop")
    |> JS.toggle_class("hidden", to: "#menu-icon-open")
    |> JS.toggle_class("hidden", to: "#menu-icon-close")
    |> JS.toggle_class("overflow-hidden", to: "body")
  end
end
