defmodule WcsStudioWeb.GraphViewLive do
  @moduledoc false
  use WcsStudioWeb, :live_view

  alias WcsStudio.{DanceType, Graph, Pattern}

  # Single source of truth for hand-position colours. Passed to the
  # PatternGraph hook via `data-colors`, so the legend and graph always match.
  @colors %{
    left_left: "#f87171",
    left_right: "#facc15",
    right_right: "#22d3ee",
    right_left: "#4ade80",
    both_hands: "#e879f9",
    starting_position: "#cbd5e1"
  }

  @legend_order [
    :left_left,
    :left_right,
    :right_right,
    :right_left,
    :both_hands,
    :starting_position
  ]

  @legend Enum.map(@legend_order, &{&1, Map.fetch!(@colors, &1)})

  @impl true
  def mount(_params, _session, socket) do
    # West Coast Swing
    dance_type_id = 1

    graph = Graph.graph_data(dance_type_id)

    {:ok,
     assign(socket,
       legend: @legend,
       colors: @colors,
       dance_type_id: dance_type_id,
       graph: graph,
       edge_count: length(graph.edges),
       selected: nil,
       practice_patterns: [],
       practice_total: 0
     )}
  end

  @impl true
  def handle_event("pattern_selected", %{"id" => id}, socket) do
    {:noreply, assign(socket, :selected, Pattern.get_by_id(id))}
  end

  def handle_event("unselect", _params, socket) do
    {:noreply, assign(socket, :selected, nil)}
  end

  def handle_event("practice", _params, socket) do
    case Graph.practice_sequence(socket.assigns.dance_type_id, 24) do
      [] ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("Couldn't build a 24-count flow from the current patterns")
         )}

      sequence ->
        {:noreply,
         socket
         |> assign(
           practice_patterns: sequence,
           practice_total: Enum.reduce(sequence, 0, &(&1.count_num + &2))
         )
         |> push_event("graph:practice", %{steps: steps_payload(sequence)})}
    end
  end

  def handle_event("replay", _params, socket) do
    {:noreply,
     push_event(socket, "graph:practice", %{
       steps: steps_payload(socket.assigns.practice_patterns)
     })}
  end

  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(practice_patterns: [], practice_total: 0)
     |> push_event("graph:reset", %{})}
  end

  defp steps_payload(patterns) do
    Enum.map(patterns, fn p ->
      %{
        edge_id: Graph.edge_id(p),
        source: to_string(p.starting_hands),
        target: to_string(p.ending_hands),
        count: p.count_num,
        name: p.name
      }
    end)
  end

  defp legend_label(:both_hands), do: "Both hands"
  defp legend_label(:starting_position), do: "Starting position"
  defp legend_label(h), do: Pattern.hands_label(h)

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Full-screen graph — negative margin cancels the layout's py-16 (4rem each)
         so the graph fills from the navbar to the bottom of the viewport.
         Nav = h-16 = 4rem. Layout main py-16 = 4rem top + 4rem bottom. --%>
    <section
      class="relative -mt-16 flex flex-col"
      style="height: calc(100dvh - 4rem); min-height: 480px;"
    >
      <%!-- Background layers --%>
      <div
        class="absolute inset-0 bg-slate-800/30 pointer-events-none"
        style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
      >
      </div>
      <div class="absolute inset-0 bg-gradient-to-br from-pink-500/5 via-purple-500/5 to-transparent pointer-events-none">
      </div>

      <%!-- Toolbar — compact, overlaid at top --%>
      <div
        class="relative z-20 flex items-center justify-between gap-3 px-3 md:px-5 py-2.5 md:py-3 border-b border-slate-700/40 bg-slate-900/60"
        style="backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);"
      >
        <div class="min-w-0">
          <h2 class="font-display uppercase font-bold text-sm md:text-lg text-white truncate">
            <i class="fas fa-project-diagram text-pink-400 mr-1.5 text-xs md:text-sm"></i>
            {gettext("Pattern Graph")}
          </h2>
          <p
            :if={@practice_patterns != []}
            class="text-[11px] md:text-xs text-slate-400 mt-0.5 truncate"
          >
            {gettext("%{count} steps across %{patterns} patterns",
              count: @practice_total,
              patterns: length(@practice_patterns)
            )}
          </p>
          <p :if={@practice_patterns == []} class="text-[11px] md:text-xs text-slate-400 mt-0.5">
            {gettext("Tap a position or a number to see its patterns · tap an arrow for details")}
          </p>
        </div>

        <div class="flex items-center gap-2 shrink-0">
          <.btn icon="random" phx-click="practice" class="!py-1.5 !px-3 !text-xs md:!text-sm">
            {gettext("Practice")}
          </.btn>
          <%= if @practice_patterns != [] do %>
            <.btn
              variant="ghost"
              icon="redo"
              phx-click="replay"
              class="!py-1.5 !px-2.5 !text-xs md:!text-sm"
            >
              {gettext("Replay")}
            </.btn>
            <.btn
              variant="ghost"
              icon="times"
              phx-click="reset"
              class="!py-1.5 !px-2.5 !text-xs md:!text-sm"
            >
              {gettext("Clear")}
            </.btn>
          <% end %>
        </div>
      </div>

      <%!-- Graph canvas + overlays wrapper — fills remaining space --%>
      <div class="relative z-10 flex-1 min-h-0">
        <%!-- Cytoscape container — absolute so it fills the wrapper without affecting flex --%>
        <div
          id="pattern-graph"
          phx-hook="PatternGraph"
          phx-update="ignore"
          data-graph={Jason.encode!(@graph)}
          data-colors={Jason.encode!(@colors)}
          class="absolute inset-0 bg-slate-900/20"
          style="background-image: radial-gradient(circle at center, rgba(168,85,247,0.06) 0%, transparent 70%);"
        >
        </div>

        <%!-- Legend — top-left overlay, hidden on small phones --%>
        <div
          class="absolute top-3 left-3 z-20 hidden sm:flex flex-col gap-1.5 p-2 rounded-lg bg-slate-900/80 border border-slate-700/50 pointer-events-none"
          style="backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);"
        >
          <span class="text-[9px] uppercase tracking-widest text-slate-500">
            {gettext("Arrow colour = starting hands")}
          </span>
          <div
            :for={{hand, color} <- @legend}
            class="flex items-center gap-1.5 text-[11px] text-slate-300"
          >
            <span class="w-2.5 h-2.5 rounded-full shrink-0" style={"background-color: #{color}"}></span>
            {legend_label(hand)}
          </div>
        </div>

        <%!-- Details panel — bottom sheet on mobile, top-right card on desktop --%>
        <aside
          class={[
            "absolute z-20 rounded-xl border border-slate-700/50 bg-slate-900/90 shadow-2xl overflow-hidden transition-all duration-200",
            "bottom-2 left-2 right-2 sm:bottom-auto sm:left-auto sm:top-3 sm:right-3 sm:w-60 md:w-68",
            !@selected && "hidden sm:block"
          ]}
          style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
        >
          <%= if @selected do %>
            <div class="relative p-3 md:p-4">
              <button
                type="button"
                phx-click="unselect"
                class="sm:hidden absolute top-2 right-2 w-7 h-7 flex items-center justify-center rounded-full bg-slate-800 text-slate-400 hover:text-white"
                aria-label="Close"
              >
                <i class="fas fa-times text-xs"></i>
              </button>
              <h3 class="font-display uppercase font-bold text-base md:text-lg bg-gradient-to-r from-pink-400 to-purple-400 bg-clip-text text-transparent mb-2 md:mb-3 pr-6 sm:pr-0">
                {@selected.name}
              </h3>

              <dl class="space-y-1.5 md:space-y-2 text-xs md:text-sm">
                <div class="flex items-center justify-between">
                  <dt class="text-slate-400">{gettext("Starting hands")}</dt>
                  <dd class="text-slate-200">{Pattern.hands_label(@selected.starting_hands)}</dd>
                </div>
                <div class="flex items-center justify-between">
                  <dt class="text-slate-400">{gettext("Ending hands")}</dt>
                  <dd class="text-slate-200">{Pattern.hands_label(@selected.ending_hands)}</dd>
                </div>
                <div class="flex items-center justify-between">
                  <dt class="text-slate-400">{gettext("Steps")}</dt>
                  <dd class="text-slate-200">{@selected.count_num || "—"}</dd>
                </div>
                <div :if={@selected.dance_type} class="flex items-center justify-between">
                  <dt class="text-slate-400">{gettext("Dance type")}</dt>
                  <dd class="text-slate-200">
                    {DanceType.get_name(@selected.dance_type, @locale)}
                  </dd>
                </div>
              </dl>

              <a
                :if={@selected.video_url}
                href={@selected.video_url}
                target="_blank"
                rel="noopener"
                class="mt-3 w-full bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600 text-white font-semibold py-2 px-4 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2 text-xs md:text-sm"
              >
                <i class="fas fa-play"></i>
                <span>{gettext("Watch video")}</span>
              </a>
            </div>
          <% else %>
            <div class="relative text-center p-3 md:p-5">
              <div class="w-9 h-9 md:w-10 md:h-10 mx-auto mb-2 rounded-full bg-slate-800/70 flex items-center justify-center">
                <i class="fas fa-hand-pointer text-sm md:text-base text-pink-400"></i>
              </div>
              <p class="text-[11px] md:text-xs text-slate-400">
                {gettext("Select an arrow to see its details")}
              </p>
            </div>
          <% end %>
        </aside>

        <%!-- Empty state --%>
        <div
          :if={@edge_count == 0}
          class="absolute inset-0 z-20 flex flex-col items-center justify-center text-center pointer-events-none"
        >
          <div class="w-16 h-16 mb-3 rounded-full bg-slate-800/50 flex items-center justify-center">
            <i class="fas fa-project-diagram text-2xl text-slate-500"></i>
          </div>
          <h3 class="text-lg font-semibold text-slate-400">{gettext("No patterns found")}</h3>
        </div>

        <%!-- Hint --%>
        <div class="hidden md:block absolute z-20 bottom-2 left-1/2 -translate-x-1/2 text-[11px] text-slate-500/70 pointer-events-none text-center px-4">
          {gettext(
            "Numbers = patterns per transition · click a number or a hand position to expand · click an arrow for details"
          )}
        </div>
      </div>
    </section>

    <%!-- Practice cards — below the graph, scrollable --%>
    <section
      :if={@practice_patterns != []}
      class="w-full max-w-[1600px] mx-auto px-2 md:px-4 py-8 md:py-12"
    >
      <div class="mb-6 md:mb-8 text-center">
        <h2 class="font-display uppercase font-bold text-2xl md:text-3xl lg:text-4xl text-white">
          {gettext("Your")}
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-pink-400 to-purple-400">
            {gettext("Flow")}
          </span>
        </h2>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
        <%= for {pattern, idx} <- Enum.with_index(@practice_patterns, 1) do %>
          <div class="group relative flex flex-col h-auto rounded-xl md:rounded-2xl overflow-hidden transition-all duration-500 hover:shadow-2xl border border-slate-700/30 hover:border-slate-600/50">
            <div
              class="absolute inset-0 bg-slate-800/50 pointer-events-none"
              style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
            >
            </div>
            <div class="absolute inset-0 bg-gradient-to-br from-pink-500/10 via-purple-500/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none">
            </div>

            <div class="relative overflow-hidden">
              <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                <iframe
                  :if={pattern.video_url}
                  class="absolute top-0 left-0 w-full h-full"
                  src={pattern.video_url}
                  title={gettext("YouTube video player")}
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen
                  loading="lazy"
                ></iframe>
                <div
                  :if={!pattern.video_url}
                  class="absolute inset-0 flex items-center justify-center bg-slate-800/60"
                >
                  <i class="fas fa-video-slash text-2xl md:text-3xl text-slate-600"></i>
                </div>
              </div>
            </div>

            <div class="relative flex-1 flex flex-col justify-between p-4 md:p-6 z-10">
              <div class="relative z-10 mb-2 md:mb-3">
                <div class="flex items-center gap-2 mb-1.5 md:mb-2">
                  <span class="w-6 h-6 md:w-7 md:h-7 rounded-full bg-gradient-to-r from-pink-500 to-purple-500 text-white text-xs md:text-sm font-bold flex items-center justify-center shrink-0">
                    {idx}
                  </span>
                  <span class="text-[11px] md:text-xs text-slate-400 truncate">
                    {Pattern.hands_label(pattern.starting_hands)} → {Pattern.hands_label(
                      pattern.ending_hands
                    )}
                  </span>
                </div>
                <h3 class="font-display uppercase font-bold text-xl md:text-2xl text-white group-hover:text-pink-200 transition-colors duration-300">
                  {pattern.name}
                </h3>
                <p class="text-xs md:text-sm text-slate-400 mt-1">
                  {gettext("%{count} steps", count: pattern.count_num)}
                </p>
              </div>

              <div class="relative flex items-center justify-end pt-2 md:pt-3 border-t border-slate-600/50 group-hover:border-slate-500/50 transition-colors duration-300 z-10">
                <a
                  href={~p"/patterns"}
                  class="text-pink-400 text-xs md:text-sm font-medium flex items-center gap-2 group-hover:gap-3 transition-all duration-300"
                >
                  <span>{gettext("Details")}</span>
                  <i class="fas fa-arrow-right group-hover:translate-x-1 transition-transform duration-300"></i>
                </a>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </section>
    """
  end
end
