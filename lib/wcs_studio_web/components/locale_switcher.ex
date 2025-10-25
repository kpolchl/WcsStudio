defmodule WcsStudioWeb.Components.LocaleSwitcher do
  use Phoenix.Component
  import WcsStudioWeb.CoreComponents
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
    <div class={["relative", @class]} id="locale-switcher-container" phx-click-away={JS.add_class("hidden", to: "#locale-dropdown")}>
      <button
        type="button"
        phx-click={JS.toggle(to: "#locale-dropdown", in: {"ease-out duration-100", "opacity-0 scale-95", "opacity-100 scale-100"}, out: {"ease-in duration-75", "opacity-100 scale-100", "opacity-0 scale-95"})}
        class="flex items-center space-x-2 p-2 rounded-lg hover:bg-slate-800/50 transition-all duration-300 border border-transparent hover:border-slate-700/50 text-slate-300 hover:text-white group"
      >
        <span class="text-sm font-medium uppercase"><%= @current_locale %></span>
        <i class="fas fa-chevron-down text-xs transition-transform duration-300 group-hover:rotate-180"></i>
      </button>

      <div
        id="locale-dropdown"
        class="hidden absolute right-0 mt-2 w-48 rounded-xl bg-slate-800/95 backdrop-blur-xl border border-slate-700/50 shadow-xl py-2 z-50"
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
                  "bg-slate-700/50 text-white"
                else
                  "text-slate-300 hover:bg-slate-700/50 hover:text-white"
                end
              ]}
            >
              <span class="text-lg mr-3"><%= locale.flag %></span>
              <div class="flex-1">
                <div class="font-medium"><%= locale.name %></div>
                <div class="text-xs text-slate-400 uppercase"><%= locale.code %></div>
              </div>
              <%= if locale.code == @current_locale do %>
                <i class="fas fa-check ml-2 text-pink-500 group-hover:text-white transition-colors"></i>
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
      <div class="text-slate-400 text-xs font-medium px-3 py-2 uppercase tracking-wider">
      </div>
      <div class="grid grid-cols-2 gap-1 px-1">
        <%= for locale <- locales() do %>
          <.link
            href={~p"/locale/#{locale.code}?redirect_to=#{@current_path}"}
            method="get"
            class={[
              "flex items-center px-3 py-3 rounded-lg text-sm transition-all duration-200 group",
              if locale.code == @current_locale do
                "bg-gradient-to-r from-pink-500/20 to-purple-500/20 text-white border border-pink-500/30"
              else
                "text-slate-300 hover:bg-slate-800/50 hover:text-white border border-transparent"
              end
            ]}
          >
            <span class="text-base mr-2"><%= locale.flag %></span>
            <span class="font-medium"><%= locale.name %></span>
            <%= if locale.code == @current_locale do %>
              <i class="fas fa-check ml-auto text-pink-500 group-hover:text-white transition-colors"></i>
            <% end %>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end


  defp get_flag(locale_code) do
    locale = Enum.find(locales(), &(&1.code == locale_code))
    locale && locale.flag || "🌐"
  end

  defp get_name(locale_code) do
    locale = Enum.find(locales(), &(&1.code == locale_code))
    locale && locale.name || locale_code
  end

  defp locales do
    @locales
  end
end