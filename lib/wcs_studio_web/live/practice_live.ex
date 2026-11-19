defmodule WcsStudioWeb.PracticeLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.DanceType
  alias WcsStudio.Pattern
  alias WcsStudio.UserPattern

  @impl true
  def mount(_params, _session, socket) do
    first_dance_type = DanceType.get_first()
    initial_patterns = Pattern.get_by_dance_type_id(first_dance_type.id)

    socket =
      assign(socket,
        patterns: initial_patterns,
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
    {:noreply, assign(socket, :random_patterns, Enum.take_random(socket.assigns.patterns, 4))}
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
    user_id = socket.assigns.current_user && socket.assigns.current_user.id
    dance_type_id = String.to_integer(id)
    selected_filter = socket.assigns.selected_filter

    {:noreply,
     socket
     |> assign(:dance_type_id, dance_type_id)
     |> assign(:selected_dance_type, DanceType.get_by_id(dance_type_id))
     |> assign(:patterns, get_patterns_by_filter(user_id, selected_filter, dance_type_id))
     |> assign(:dropdown_open, false)}
  end

  @impl true
  def handle_event("selected_filter", %{"selected_filter" => selected_filter}, socket) do
    user_id = socket.assigns.current_user && socket.assigns.current_user.id
    dance_type_id = socket.assigns.dance_type_id

    {:noreply,
     socket
     |> assign(:selected_filter, selected_filter)
     |> assign(:patterns, get_patterns_by_filter(user_id, selected_filter, dance_type_id))}
  end

  defp get_patterns_by_filter(user_id, filter, dance_type_id) do
    case user_id do
      nil -> Pattern.get_by_dance_type_id(dance_type_id)
      _ -> UserPattern.get_user_patterns_by_status_and_dance_type(user_id, filter, dance_type_id)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Header Section -->
    <.header size={:lg} gradient centered style="-webkit-text-fill-color: transparent;">
      {gettext("Practice")}
      <:subtitle>
        {gettext("As the number of steps grows larger one must find a way to practice them.")}
      </:subtitle>
    </.header>

    <!-- Filter section -->
    <div class="px-4 mb-4">
      <div class="max-w-6xl mx-auto">
        <!-- Style Filters -->
        <div class="flex flex-wrap justify-center gap-3 mb-8">
          <button
            type="button"
            phx-click="selected_filter"
            phx-value-selected_filter="all"
            class={[
              "px-4 py-2 rounded-md font-medium transition-all duration-300 flex items-center",
              if @selected_filter == "all" do
                "bg-gradient-to-r from-brand-from to-brand-to text-strong shadow-raised shadow-brand-from/25"
              else
                "bg-surface-raised/50 hover:bg-surface-muted/50 text-body border border-surface-muted/50"
              end
            ]}
          >
            <i class="fas fa-layer-group mr-2"></i> {gettext("All")}
          </button>

          <%= if @current_user do %>
            <button
              type="button"
              phx-click="selected_filter"
              phx-value-selected_filter="in_progress"
              class={[
                "px-4 py-2 rounded-md font-medium transition-all duration-300 flex items-center",
                if @selected_filter == "in_progress" do
                  "bg-gradient-to-r from-brand-from to-brand-to text-strong shadow-raised shadow-brand-from/25"
                else
                  "bg-surface-raised/50 hover:bg-surface-muted/50 text-body border border-surface-muted/50"
                end
              ]}
            >
              <i class="fas fa-spinner mr-2 "></i> {gettext("In Progress")}
            </button>

            <button
              type="button"
              phx-click="selected_filter"
              phx-value-selected_filter="learned"
              class={[
                "px-4 py-2 rounded-md font-medium transition-all duration-300 flex items-center",
                if @selected_filter == "learned" do
                  "bg-gradient-to-r from-brand-from to-brand-to text-strong shadow-raised shadow-brand-from/25"
                else
                  "bg-surface-raised/50 hover:bg-surface-muted/50 text-body border border-surface-muted/50"
                end
              ]}
            >
              <i class="fas fa-check-circle mr-2"></i> {gettext("Learned")}
            </button>
          <% end %>
        </div>
      </div>
    </div>

    <!-- Dance type dropdown buttons -->
    <div class="w-full max-w-2xl mx-auto px-4 mb-8 relative z-50">
      <div
        class="flex flex-col sm:flex-row gap-3 p-4 bg-surface-raised/30 rounded-md border border-surface-muted/50 shadow-raised"
        style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
      >
        <div class="flex-1 relative" id="dance-type-selector">
          <div phx-click-away="close_dropdown" class="relative h-full">
            <button
              type="button"
              phx-click="toggle_dropdown"
              class="w-full h-full py-3 pl-4 pr-4 text-left bg-surface-muted/50 text-body border border-surface-muted rounded-lg hover:border-brand-from/40 focus:outline-none focus:ring-1 focus:ring-brand-from transition-all duration-200 flex items-center justify-between"
            >
              <div class="flex items-center ">
                <span>
                  <%= if @selected_dance_type do %>
                    {DanceType.get_name(@selected_dance_type, @locale)}
                  <% else %>
                    {gettext("Select Dance Type")}
                  <% end %>
                </span>
              </div>
              <i class={[
                "fas fa-chevron-down text-muted text-xs transition-transform duration-300",
                if(@dropdown_open, do: "rotate-180", else: "")
              ]}></i>
            </button>

            <div
              :if={@dropdown_open}
              class="absolute z-[9999] mt-2 w-full bg-surface-raised/90 border border-surface-muted/50 rounded-lg shadow-raised overflow-hidden animate-fade-in"
              style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
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
                          do: "bg-brand-hoverFrom/40 text-strong",
                          else: "hover:bg-surface-muted/70 text-body"
                        )
                      ]}
                    >
                      {DanceType.get_name(dance_type, @locale)}
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
      <.button type="button" phx-click="random_practice" size={:lg} class="w-full">
        <i class="fas fa-random"></i>
        <span>{gettext("Start Practice")}</span>
      </.button>
    </div>

    <!-- Selected random patterns -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 lg:px-2">
      <%= for random_pattern <- @random_patterns do %>
        <div class="group relative flex flex-col h-auto rounded-lg overflow-hidden transition-all duration-500  hover:shadow-card border border-surface-muted/30 hover:border-surface-muted">
          <!-- Background -->
          <div
            class="absolute inset-0 bg-surface-raised/50 backdrop-blur-sm pointer-events-none"
            style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
          >
          </div>
          <div class="absolute inset-0 bg-gradient-to-br from-brand-from/10 via-brand-to/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
          </div>

          <!-- Video Section -->
          <div class="relative overflow-hidden">
            <!-- Video -->
            <div class="w-full rounded-lg overflow-hidden">
              <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                <iframe
                  class="absolute top-0 left-0 w-full h-full"
                  src={random_pattern.video_url}
                  title={gettext("YouTube video player")}
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen
                  loading="lazy"
                ></iframe>
              </div>
            </div>
          </div>

          <!-- Content Section -->
          <div class="relative flex-1 flex flex-col justify-between p-6 z-10">
            <!-- Background Effects (moved to content area) -->
            <div class="absolute top-0 right-0 w-32 h-32 bg-brand-from rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500 pointer-events-none">
            </div>
            <div class="absolute bottom-0 left-0 w-32 h-32 bg-brand-to rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500 pointer-events-none">
            </div>

            <div class="relative z-10">
              <h1 class="text-3xl font-bold text-strong mb-2 group-hover:text-brand-lightFrom transition-colors duration-300">
                {random_pattern.name}
              </h1>
            </div>

            <!-- CTA -->
            <div class="relative flex items-center justify-end pt-3 border-t border-surface-muted group-hover:border-slate-500/50 transition-colors duration-300 z-10">
              <a
                href={~p"/patterns"}
                class="text-brand-lightFrom text-sm font-medium flex items-center gap-2 group-hover:gap-3 transition-all duration-300"
              >
                <span>{gettext("Details")}</span>
                <i class="fas fa-arrow-right group-hover:translate-x-1 transition-transform duration-300"></i>
              </a>
            </div>
          </div>
        </div>
      <% end %>
    </div>

    <!-- Empty State -->
    <%= if Enum.empty?(@random_patterns) do %>
      <%= cond do %>
        <% @selected_filter != "all" -> %>
          <.empty_state
            icon="fas fa-dumpster-fire"
            title={gettext("Gotta practice more to see something here")}
          />
        <% true -> %>
          <.empty_state
            icon="fas fa-dice"
            title={gettext("Click Start Practice to draw 4 random steps")}
          />
      <% end %>
    <% end %>
    """
  end
end
