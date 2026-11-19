defmodule WcsStudioWeb.Components.LocaleSwitcher do
  @moduledoc false
  use Phoenix.Component
  use WcsStudioWeb, :verified_routes
  alias Phoenix.LiveView.JS

  @locales [
    %{code: "en", name: "English", flag: "🇬🇧"},
    %{code: "pl", name: "Polski", flag: "🇵🇱"}
  ]

  attr :current_locale, :string, default: "pl"
  attr :current_path, :string, default: "/"
  attr :class, :string, default: ""

  def locale_switcher(assigns) do
    assigns = assign_new(assigns, :current_path, fn -> "/" end)

    ~H"""
    <div
      class={["relative", @class]}
      id="locale-switcher-container"
      phx-click-away={JS.add_class("hidden", to: "#locale-dropdown")}
    >
      <button
        type="button"
        phx-click={
          JS.toggle(
            to: "#locale-dropdown",
            in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"},
            out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"}
          )
        }
        class="flex items-center space-x-2 p-2 rounded-lg hover:bg-surface-raised/50 transition-all duration-300 border border-transparent hover:border-surface-muted/50 text-body hover:text-strong group"
      >
        <span class="text-sm font-medium uppercase">{@current_locale}</span>
        <i class="fas fa-chevron-down text-xs transition-transform duration-300 group-hover:rotate-180"></i>
      </button>

      <div
        id="locale-dropdown"
        class="hidden absolute right-0 mt-2 w-48 rounded-md bg-surface-raised/95 backdrop-blur-xl border border-surface-muted/50 shadow-card py-2 z-50"
        phx-update="ignore"
      >
        <div class="py-1">
          <%= for locale <- locales() do %>
            <.link
              href={~p"/locale/#{locale.code}?redirect_to=#{@current_path}"}
              method="get"
              class={[
                "flex items-center px-4 py-3 text-sm transition-colors duration-200 group",
                if locale.code == @current_locale do
                  "bg-surface-muted/50 text-strong"
                else
                  "text-body hover:bg-surface-muted/50 hover:text-strong"
                end
              ]}
            >
              <span class="text-lg mr-3">{locale.flag}</span>
              <div class="flex-1">
                <div class="font-medium">{locale.name}</div>
                <div class="text-xs text-muted uppercase">{locale.code}</div>
              </div>
              <%= if locale.code == @current_locale do %>
                <i class="fas fa-check ml-2 text-brand-from group-hover:text-strong transition-colors"></i>
              <% end %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Wersja mobilna (select)
  attr :current_locale, :string, default: "pl"
  attr :current_path, :string, default: "/"
  attr :class, :string, default: ""

  def mobile_locale_switcher(assigns) do
    assigns = assign_new(assigns, :current_path, fn -> "/" end)

    ~H"""
    <div class={["w-full", @class]}>
      <div class="grid grid-cols-2 gap-1 px-1">
        <%= for locale <- locales() do %>
          <.link
            href={~p"/locale/#{locale.code}?redirect_to=#{@current_path}"}
            method="get"
            class={[
              "flex items-center px-3 py-3 rounded-lg text-sm transition-all duration-200 group",
              if locale.code == @current_locale do
                "bg-gradient-to-r from-brand-from/20 to-brand-to/20 text-strong border border-brand-from/30"
              else
                "text-body hover:bg-surface-raised/50 hover:text-strong border border-transparent"
              end
            ]}
          >
            <span class="text-base mr-2">{locale.flag}</span>
            <span class="font-medium">{locale.name}</span>
            <%= if locale.code == @current_locale do %>
              <i class="fas fa-check ml-auto text-brand-from group-hover:text-strong transition-colors"></i>
            <% end %>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  defp locales do
    @locales
  end
end
