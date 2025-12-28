defmodule WcsStudioWeb.PracticeLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Pattern
  alias WcsStudio.DanceType
  alias WcsStudio.UserPattern

  @impl true
  def mount(_params, _session, socket) do
    first_dance_type = DanceType.get_first()

    socket = assign(socket,
      patterns: Pattern.get_all(),
      dance_types: DanceType.get_all(),
      dance_type_id: first_dance_type.id,
      selected_dance_type: DanceType.get_by_id(first_dance_type.id),
      random_patterns: [],
      dropdown_open: false,
      selected_filter: "all"
    )
    {:ok, socket}
  end

  @impl true
  def handle_event("random_practice", _params, socket) do
    {:noreply,
      assign(socket, :random_patterns,
        Enum.take_random(socket.assigns.patterns, 4)
      )}
  end


  @impl true
  def handle_event("toggle_dropdown", _, socket) do
    {:noreply, assign(socket, :dropdown_open, !socket.assigns[:dropdown_open])}
  end

  @impl true
  def handle_event("close_dropdown", _, socket) do
    {:noreply, assign(socket, :dropdown_open, false)}
  end

  @impl true
  def handle_event("choose", %{"dance_type_id" => id}, socket) do
    dance_type_id = String.to_integer(id)

    {:noreply,
      socket
      |> assign(:dance_type_id, dance_type_id)
      |> assign(:selected_dance_type, DanceType.get_by_id(dance_type_id))
      |> assign(:patterns, Pattern.get_by_dance_type_id(dance_type_id))
      |> assign(:dropdown_open, false)}
  end

  @impl true
  def handle_event("selected_filter", %{"selected_filter" => selected_filter}, socket) do
    {:noreply,
      socket
      |> assign(:selected_filter, selected_filter)
      |> assign(:patterns, get_patterns_by_filter(selected_filter ,socket))}
  end

  defp get_patterns_by_filter(filter, socket), do: UserPattern.get_user_patterns_by_status_and_dance_type(socket.assigns.current_user.id, filter, socket.assigns.selected_dance_type.id)

  @impl true
  def render(assigns) do
    ~H"""
      <!-- Header Section -->
      <div class="mb-12 text-center px-4">
        <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
          <%= gettext("Practice") %>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          <%= gettext("As the number of steps grows larger one must find a way to practice them.") %>
        </p>
      </div>


      <!-- Filter section -->
      <div class="px-4 mb-4">
        <div class="max-w-6xl mx-auto">
          <!-- Style Filters -->
          <div class="flex flex-wrap justify-center gap-3 mb-8">
            <button
              phx-click="selected_filter"
              phx-value-selected_filter="all"
              class={[
                "px-4 py-2 rounded-xl font-medium transition-all duration-300 flex items-center",
                if @selected_filter == "all" do
                  "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
                else
                  "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
                end
              ]}
            >
              <i class="fas fa-layer-group mr-2"></i> <%= gettext("All")%>
            </button>

            <button
              phx-click="selected_filter"
              phx-value-selected_filter="in_progress"
              class={[
                "px-4 py-2 rounded-xl font-medium transition-all duration-300 flex items-center",
                if @selected_filter == "in_progress" do
                  "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
                else
                  "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
                end
              ]}
            >
                  <i class="fas fa-spinner mr-2 "></i> <%= gettext("In Progress")%>
            </button>

            <button
              phx-click="selected_filter"
              phx-value-selected_filter="learned"
              class={[
                "px-4 py-2 rounded-xl font-medium transition-all duration-300 flex items-center",
                if @selected_filter == "learned" do
                  "bg-gradient-to-r from-pink-500 to-purple-500 text-white shadow-lg shadow-pink-500/25"
                else
                  "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50"
                end
              ]}
            >
              <i class="fas fa-check-circle mr-2"></i> <%= gettext("Learned")%>
            </button>
          </div>
        </div>
      </div>

      <!-- Dance type dropdown buttons -->
      <div class="w-full max-w-2xl mx-auto px-4 mb-8">
        <div class="flex flex-col sm:flex-row gap-3 p-4 bg-slate-800/30 rounded-xl border border-slate-700/50 shadow-lg">
          <div class="flex-1 relative isolation-auto" id="dance-type-selector">
            <div phx-click-away="close_dropdown" class="relative h-full">
              <button
                type="button"
                phx-click="toggle_dropdown"
                class="w-full h-full py-3 pl-4 pr-4 text-left bg-slate-700/50 text-slate-200 border border-slate-600/50 rounded-lg hover:border-pink-500/40 focus:outline-none focus:ring-1 focus:ring-pink-500 transition-all duration-200 flex items-center justify-between"
              >
                <div class="flex items-center ">
                  <span>
                    <%= if @selected_dance_type do %>
                      <%= DanceType.get_name(@selected_dance_type, @locale) %>
                    <% else %>
                      <%= gettext("Select Dance Type") %>
                    <% end %>
                  </span>
                </div>
                <i class={["fas fa-chevron-down text-slate-400 text-xs transition-transform duration-300", if(@dropdown_open, do: "rotate-180", else: "group-hover:rotate-180")]}></i>
              </button>

              <div
                :if={@dropdown_open}
                class="absolute z-[9999] mt-2 w-full bg-slate-800/90 border border-slate-700/50 rounded-lg shadow-lg overflow-hidden animate-fade-in"
              >
                <ul class="max-h-56 overflow-y-auto">
                  <%= for dance_type <- @dance_types do %>
                    <li>
                      <button
                        type="button"
                        phx-click="choose"
                        phx-value-dance_type_id={dance_type.id}
                        class={[
                          "w-full text-left px-4 py-2 text-sm transition-all duration-150",
                          if(dance_type.id == @dance_type_id,
                            do: "bg-pink-600/40 text-white",
                            else: "hover:bg-slate-700/70 text-slate-200"
                          )
                        ]}
                      >
                        <%= DanceType.get_name(dance_type, @locale) %>
                      </button>
                    </li>
                  <% end %>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Random practice Button -->
      <div class="w-full max-w-2xl mx-auto px-4 mb-8">
        <button
          phx-click="random_practice"
          class="w-full bg-gradient-to-r from-pink-500 to-purple-500 text-white font-semibold py-4 px-6 rounded-lg shadow-lg flex items-center justify-center gap-2">
          <span><%= gettext("Start Practice") %></span>
        </button>
      </div>

      <!-- Selected random patterns -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 lg:px-2">
        <%= for random_pattern <- @random_patterns do %>
          <div class={"group bg-slate-800/60 backdrop-blur-sm border border-white/5 rounded-xl p-5"}>
            <div class="flex items-start justify-center mb-3">
              <h2 class="text-3xl font-semibold text-white"><%= random_pattern.name %></h2>
            </div>

            <p class="text-slate-400 text-sm mb-4 line-clamp-2 leading-relaxed">
              <%= if @locale == "en" do %>
                <%= random_pattern.general_description_en %>
              <% else %>
                <%= random_pattern.general_description_pl %>
              <% end %>
            </p>

            <div class="w-full rounded-lg shadow-lg overflow-hidden pl-2 pr-2 pb-2 ">
              <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                <iframe
                  class="absolute top-0 left-0 w-full h-full"
                  src={random_pattern.video_url}
                  title={gettext("YouTube video player")}
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen>
                </iframe>
              </div>
            </div>

            <div class="flex items-center justify-between pt-3 border-t border-white/5">
              <a href={~p"/patterns"} class="text-blue-400 text-xs font-medium flex items-center gap-1">
                <span><%= gettext("Details")%></span>
                <i class="fas fa-arrow-right text-[10px]"></i>
              </a>
            </div>
          </div>
        <% end %>
      </div>

      <!-- Empty State -->
      <%= if Enum.empty?(@random_patterns) do %>
        <div class="text-center py-16">
          <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-slate-800/50 flex items-center justify-center">
            <i class="fas fa-dice text-3xl text-slate-500"></i>
          </div>
          <h3 class="text-xl font-semibold text-slate-400 mb-2"><%= gettext("Click Start Practice to draw 4 random steps") %></h3>
        </div>
      <% end %>

    """
  end
end
