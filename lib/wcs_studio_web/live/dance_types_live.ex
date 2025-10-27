defmodule WcsStudioWeb.DanceTypesLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.DanceType

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        selected_dance_type_type: "all"
      )
    {:ok, socket}
  end

  @impl true
  def handle_event("select_type_type", %{"dance_type_type" => dance_type_type}, socket) do
    {:noreply,
      socket
      |> assign(:selected_dance_type_type, dance_type_type)
      |> assign(:dance_types, get_dance_types_by_type(dance_type_type))}
  end

  defp get_dance_types_by_type("all"), do: DanceType.get_all()
  defp get_dance_types_by_type(type), do: DanceType.get_by_type(type)

  @impl true
  def render(assigns) do
    ~H"""
    <section class="py-16 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
          <%= gettext("Dance Types")%>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto leading-relaxed">
           <%= gettext("Browse through variable dance styles, from around the world that admin is learning or already knows.")%>
        </p>
      </div>
    </section>

    <!-- Enhanced Filter System -->
    <section class="px-4 mb-16">
      <div class="max-w-6xl mx-auto">
        <!-- Style Filters -->
        <div class="flex flex-wrap justify-center gap-3 mb-8">
          <button
            phx-click="select_type_type"
            phx-value-dance_type_type="all"
            class={[
              "px-6 py-3 rounded-xl font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "all" do
                "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
              else
                "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
              end
            ]}
          >
            <i class="fas fa-layer-group mr-2"></i> <%= gettext("All Styles")%>
          </button>

          <button
            phx-click="select_type_type"
            phx-value-dance_type_type="latin"
            class={[
              "px-6 py-3 rounded-xl font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "latin" do
                "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
              else
                "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
              end
            ]}
          >
                <i class="fas fa-fire mr-2 "></i> <%= gettext("Latin")%>
          </button>

          <button
            phx-click="select_type_type"
            phx-value-dance_type_type="swing"
            class={[
              "px-6 py-3 rounded-xl font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "swing" do
                "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
              else
                "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
              end
            ]}
          >
            <i class="fas fa-sync-alt mr-2"></i> <%= gettext("Swing")%>
          </button>

          <button
            phx-click="select_type_type"
            phx-value-dance_type_type="social"
            class={[
              "px-6 py-3 rounded-xl font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "social" do
                "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
              else
                "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
              end
            ]}
          >
            <i class="fas fa-users mr-2"></i> <%= gettext("Social")%>
          </button>
        </div>
      </div>
    </section>

    <!--Card Grid -->
    <section class="px-4 pb-16">
      <div class="max-w-7xl mx-auto">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <%= for dance_type <- @dance_types do %>
            <.link
              navigate={~p"/patterns"}
              class="dance-card group relative flex flex-col h-80 rounded-2xl overflow-hidden transition-all duration-500 hover:-translate-y-2 hover:shadow-2xl"
            >
              <!-- Glass morphism background -->
              <div class="absolute inset-0 bg-slate-800/50 backdrop-blur-sm border border-slate-700/50"></div>

              <!-- Animated gradient overlay -->
              <div class="absolute inset-0 bg-gradient-to-br from-pink-500/10 via-purple-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>

              <!-- Background effects -->
              <div class="absolute inset-0">
                <div class="absolute top-0 right-0 w-32 h-32 bg-pink-500 rounded-full blur-3xl opacity-20"></div>
                <div class="absolute bottom-0 left-0 w-32 h-32 bg-purple-500 rounded-full blur-3xl opacity-20"></div>
              </div>

              <!-- Content -->
              <div class="relative flex-1 flex flex-col justify-end p-6 z-10">
                <h3 class="text-2xl font-bold text-white mb-2"><%= DanceType.get_name(dance_type , @locale) %></h3>
                <p class="text-pink-300 text-sm mb-4 flex items-center">
                  <i class="fas fa-globe-americas mr-2"></i>
                  <%= DanceType.get_country(dance_type , @locale) %>
                </p>

                <div class="flex items-center justify-between">
                  <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-white/10 text-white backdrop-blur-sm border border-white/20">
                    <i class="fas fa-tag mr-1"></i>
                    <%= dance_type.type %>
                  </span>
                  <i class="fas fa-arrow-right text-white transform group-hover:translate-x-2 transition-transform duration-300"></i>
                </div>
              </div>
            </.link>
          <% end %>
        </div>

        <!-- Empty State -->
        <%= if Enum.empty?(@dance_types) do %>
          <div class="text-center py-16">
            <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-slate-800/50 flex items-center justify-center">
              <i class="fas fa-music text-3xl text-slate-500"></i>
            </div>
            <h3 class="text-xl font-semibold text-slate-400 mb-2"><%= gettext("No dance types found ")%></h3>
            <p class="text-slate-500"> <%= gettext("Try selecting a different filter")%></p>
          </div>
        <% end %>
      </div>
    </section>
    """
  end
end