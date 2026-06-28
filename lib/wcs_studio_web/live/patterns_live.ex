defmodule WcsStudioWeb.PatternsLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.{Pattern, DanceType, UserPattern, VideoProcess}

  @filter_values ~w(all roots_only)

  @impl true
  def mount(_params, _session, socket) do
    first_dance_type = DanceType.get_first()
    patterns = Pattern.get_roots_with_children(first_dance_type.id)

    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        dance_type_id: first_dance_type.id,
        selected_dance_type: first_dance_type,
        patterns: patterns,
        query: "",
        form: to_form(Ecto.Changeset.change(%Pattern{})),
        modal_state: nil,
        expanded_pattern_id: nil,
        dropdown_open: false,
        pattern_filter: :all,
        expanded_children_id: nil,
        expanded_children_ids: MapSet.new(),
        child_candidates: [],
        selected_child_ids: MapSet.new()
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    status_map =
      case socket.assigns[:current_user] do
        nil -> %{}
        current_user -> build_status_map(current_user.id)
      end

    {:noreply,
     socket
     |> assign(:status_map, status_map)
     |> assign(:expanded_pattern_id, nil)
     |> assign(:expanded_children_id, nil)
     |> assign(:expanded_children_ids, MapSet.new())}
  end

  # -- Pattern expansion / search ----------------------------------------------

  @impl true
  def handle_event("toggle_pattern", %{"id" => id}, socket) do
    id = String.to_integer(id)
    new_id = if socket.assigns.expanded_pattern_id == id, do: nil, else: id
    {:noreply, assign(socket, :expanded_pattern_id, new_id)}
  end

  def handle_event("toggle_children", %{"id" => id}, socket) do
    id = String.to_integer(id)
    expanded_ids = socket.assigns.expanded_children_ids

    new_ids =
      if MapSet.member?(expanded_ids, id),
        do: MapSet.delete(expanded_ids, id),
        else: MapSet.put(expanded_ids, id)

    # Keep expanded_children_id in sync for components that rely on it
    new_single_id = if MapSet.member?(new_ids, id), do: id, else: nil

    {:noreply,
     assign(socket,
       expanded_children_id: new_single_id,
       expanded_children_ids: new_ids
     )}
  end

  def handle_event("search", %{"query" => query}, socket) do
    patterns =
      if query == "" do
        Pattern.get_roots_with_children(socket.assigns.dance_type_id)
      else
        Pattern.get_by_id_name_or_hands(socket.assigns.dance_type_id, query)
      end

    # When searching, auto‑expand all patterns that have children
    expanded_children_ids =
      if query == "" do
        MapSet.new()
      else
        patterns
        |> Enum.filter(&(not Enum.empty?(Map.get(&1, :children, []))))
        |> MapSet.new(& &1.id)
      end

    {:noreply,
     assign(socket,
       patterns: patterns,
       query: query,
       expanded_children_ids: expanded_children_ids,
       expanded_children_id: nil
     )}
  end

  # -- Modal open/close -------------------------------------------------------

  def handle_event("open_modal", _, socket) do
    {:noreply,
     socket
     |> assign_child_candidates()
     |> assign(
       modal_state: :create,
       form: to_form(Ecto.Changeset.change(%Pattern{})),
       selected_child_ids: MapSet.new()
     )}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply,
     assign(socket,
       modal_state: nil,
       child_candidates: [],
       selected_child_ids: MapSet.new()
     )}
  end

  def handle_event("open_update_modal", %{"id" => id}, socket) do
    id = String.to_integer(id)
    pattern = Pattern.get_by_id_with_children(id)

    child_candidates =
      Pattern.get_all_for_dance_type(socket.assigns.dance_type_id)
      |> Enum.reject(&(&1.id == id))

    pre_selected = MapSet.new(pattern.children, & &1.id)

    {:noreply,
     socket
     |> assign(
       modal_state: {:edit, pattern},
       form: to_form(Ecto.Changeset.change(pattern)),
       child_candidates: child_candidates,
       selected_child_ids: pre_selected
     )}
  end

  # -- Child selection toggling -----------------------------------------------

  def handle_event("toggle_child_selection", %{"id" => id}, socket) do
    id = String.to_integer(id)
    current_ids = socket.assigns.selected_child_ids

    new_ids =
      if MapSet.member?(current_ids, id),
        do: MapSet.delete(current_ids, id),
        else: MapSet.put(current_ids, id)

    {:noreply, assign(socket, :selected_child_ids, new_ids)}
  end

  # -- Form submissions -------------------------------------------------------

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("save", %{"pattern" => pattern_params}, socket) do
    attrs = build_pattern_attrs(pattern_params, socket.assigns.dance_type_id)

    case Pattern.add(attrs) do
      {:ok, new_pattern} ->
        Enum.each(socket.assigns.selected_child_ids, &Pattern.set_parent(&1, new_pattern.id))

        {:noreply,
         socket
         |> assign(modal_state: nil, child_candidates: [], selected_child_ids: MapSet.new())
         |> put_flash(:success, "Pattern created successfully!")
         |> push_navigate(to: ~p"/patterns")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("update_pattern", %{"pattern" => pattern_params}, socket) do
    with {:edit, pattern} <- socket.assigns.modal_state do
      attrs = build_pattern_attrs(pattern_params, pattern.dance_type_id)

      case Pattern.update(pattern, attrs) do
        {:ok, updated_pattern} ->
          update_child_associations(pattern, updated_pattern, socket.assigns.selected_child_ids)
          updated_patterns = Pattern.get_roots_with_children(socket.assigns.dance_type_id)

          {:noreply,
           socket
           |> assign(
             patterns: updated_patterns,
             modal_state: nil,
             child_candidates: [],
             selected_child_ids: MapSet.new()
           )
           |> put_flash(:success, "Pattern updated successfully!")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("delete_pattern", %{"id" => id}, socket) do
    case Pattern.delete_pattern(id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:success, "Pattern deleted successfully!")
         |> push_navigate(to: ~p"/patterns")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete pattern")}
    end
  end

  # -- Filters & dance type selection -----------------------------------------

  def handle_event("toggle_dropdown", _, socket) do
    {:noreply, assign(socket, :dropdown_open, !socket.assigns.dropdown_open)}
  end

  def handle_event("close_dropdown", _, socket) do
    {:noreply, assign(socket, :dropdown_open, false)}
  end

  def handle_event("choose", %{"dance_type_id" => id}, socket) do
    dance_type_id = String.to_integer(id)
    patterns = Pattern.get_roots_with_children(dance_type_id)

    {:noreply,
     socket
     |> assign(
       dance_type_id: dance_type_id,
       selected_dance_type: DanceType.get_by_id(dance_type_id),
       patterns: patterns,
       pattern_filter: :all,
       query: "",
       dropdown_open: false,
       expanded_children_id: nil,
       expanded_children_ids: MapSet.new()
     )}
  end

  def handle_event("filter_patterns", %{"filter" => filter}, socket)
      when filter in @filter_values do
    dance_type_id = socket.assigns.dance_type_id

    patterns =
      case filter do
        "all" -> Pattern.get_roots_with_children(dance_type_id)
        "roots_only" -> Pattern.get_roots_without_children(dance_type_id)
      end

    {:noreply,
     assign(socket,
       patterns: patterns,
       pattern_filter: String.to_existing_atom(filter),
       expanded_children_id: nil,
       expanded_children_ids: MapSet.new(),
       query: ""
     )}
  end

  def handle_event("filter_patterns", _, socket), do: {:noreply, socket}

  # -- User status updates ----------------------------------------------------

  def handle_event(
        "update_status",
        %{"pattern_id" => pattern_id, "user_id" => user_id, "status" => status},
        socket
      ) do
    pattern_id_int = String.to_integer(pattern_id)

    new_status =
      case status do
        "not_started" -> "in_progress"
        "in_progress" -> "learned"
        _ -> "learned"
      end

    case UserPattern.get_user_pattern(user_id, pattern_id_int) do
      nil -> UserPattern.add(pattern_id_int, user_id, new_status)
      user_pattern -> UserPattern.update_status(user_pattern, pattern_id_int, user_id, new_status)
    end

    updated_status_map = Map.put(socket.assigns.status_map, pattern_id_int, new_status)

    {:noreply,
     socket
     |> assign(:status_map, updated_status_map)
     |> put_flash(:info, "Status updated to #{new_status}!")}
  end

  # -- Private helpers --------------------------------------------------------

  defp build_pattern_attrs(params, dance_type_id) do
    %{
      dance_type_id: dance_type_id,
      name: params["name"],
      starting_hands: nilify_empty(params["starting_hands"]),
      ending_hands: nilify_empty(params["ending_hands"]),
      count_num: params["count_num"],
      video_url: params |> Map.get("video_url", "") |> VideoProcess.parse_youtube_url()
    }
  end

  defp nilify_empty(""), do: nil
  defp nilify_empty(val), do: val

  defp assign_child_candidates(socket) do
    candidates = Pattern.get_all_for_dance_type(socket.assigns.dance_type_id)
    assign(socket, :child_candidates, candidates)
  end

  defp build_status_map(user_id) do
    user_id
    |> UserPattern.get_user_patterns()
    |> Enum.reduce(%{}, fn up, acc -> Map.put(acc, up.pattern_id, up.status) end)
  end

  defp update_child_associations(old_pattern, updated_pattern, selected_child_ids) do
    previous = MapSet.new(old_pattern.children, & &1.id)

    # Add parent to newly selected children
    selected_child_ids
    |> MapSet.difference(previous)
    |> Enum.each(&Pattern.set_parent(&1, updated_pattern.id))

    # Remove parent from deselected children
    previous
    |> MapSet.difference(selected_child_ids)
    |> Enum.each(&Pattern.remove_parent/1)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- Header Section -->
    <div class="mb-12 text-center px-4">
      <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
        {gettext("Steps")}
      </h1>
      <p class="text-xl text-slate-400 max-w-2xl mx-auto">
        {gettext(
          "Explore our collection of dance moves with step-by-step instructions, video demonstrations, and detailed breakdowns for leaders and followers."
        )}
      </p>
    </div>

    <!-- Add Pattern Button (Admin Only) -->
    <%= if @current_user && @current_user.role == "admin" do %>
      <div class="w-full max-w-2xl mx-auto px-4 mb-8">
        <button
          phx-click="open_modal"
          class="w-full sm:w-auto bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600 text-white font-semibold py-3 px-6 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2"
        >
          <i class="fas fa-plus"></i>
          <span>{gettext("Add New Pattern")}</span>
        </button>
      </div>
    <% end %>

    <!-- Filters Section -->
    <div class="w-full max-w-2xl mx-auto px-4 mb-8">
      <div class="flex flex-col sm:flex-row gap-3 p-4 bg-slate-800/30 rounded-xl border border-slate-700/50 shadow-lg">
        <!-- Dance Type Selector -->
        <div class="flex-1 relative isolation-auto" id="dance-type-selector">
          <div phx-click-away="close_dropdown" class="relative h-full">
            <button
              type="button"
              phx-click="toggle_dropdown"
              class="w-full h-full py-3 pl-4 pr-4 text-left bg-slate-700/50 text-slate-200 border border-slate-600/50 rounded-lg hover:border-pink-500/40 focus:outline-none focus:ring-1 focus:ring-pink-500 transition-all duration-200 flex items-center justify-between"
            >
              <div class="flex items-center">
                <span>
                  <%= if @selected_dance_type do %>
                    {DanceType.get_name(@selected_dance_type, @locale)}
                  <% else %>
                    {gettext("Select Dance Type")}
                  <% end %>
                </span>
              </div>
              <i class={[
                "fas fa-chevron-down text-slate-400 text-xs transition-transform duration-300",
                if(@dropdown_open, do: "rotate-180", else: "group-hover:rotate-180")
              ]}>
              </i>
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
                      {DanceType.get_name(dance_type, @locale)}
                    </button>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>
        </div>
        
    <!-- Search Input -->
        <div class="flex-1 relative">
          <form phx-change="search" class="h-full">
            <div class="relative h-full">
              <div class="pl-1 absolute left-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                <i class="fas fa-search text-slate-400 text-sm"></i>
              </div>
              <div class="relative">
                <input
                  type="search"
                  name="query"
                  value={@query}
                  placeholder="Type to search"
                  class="relative z-10 w-full h-full
                         pl-10 pr-8 py-3
                         bg-slate-700/50 text-slate-200
                         border border-slate-600/50
                         rounded-lg
                         focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Patterns list -->
    <div class="mt-4 lg:p-4 flex flex-col items-center">
      <%= for pattern <- @patterns do %>
        <.pattern
          pattern={pattern}
          is_child={false}
          expanded_children_id={@expanded_children_id}
          expanded_children_ids={@expanded_children_ids}
          current_user={@current_user}
          expanded_pattern_id={@expanded_pattern_id}
          status={@status_map[pattern.id]}
          status_map={@status_map}
          locale={@locale}
        />
        <%= if @current_user && @current_user.role == "admin" do %>
          <.confirm_modal
            id={"confirm-delete-pattern-#{pattern.id}"}
            title={gettext("Delete Pattern?")}
            message={
              gettext(
                "Are you sure you want to delete '%{name}'? This action cannot be undone and will remove all associated data.",
                name: pattern.name
              )
            }
            confirm_event="delete_pattern"
            confirm_value={pattern.id}
          />
        <% end %>
      <% end %>
    </div>

    <!-- Empty State -->
    <%= if Enum.empty?(@patterns) do %>
      <div class="text-center py-16">
        <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-slate-800/50 flex items-center justify-center">
          <i class="fas fa-music text-3xl text-slate-500"></i>
        </div>
        <h3 class="text-xl font-semibold text-slate-400 mb-2">{gettext("No patterns found")}</h3>
        <p class="text-slate-500">
          {gettext("Try selecting a different filter or adjusting your search")}
        </p>
      </div>
    <% end %>

    <!-- Modals -->
    <%= case @modal_state do %>
      <% :create -> %>
        <.form_modal
          id="new-pattern-modal"
          show={true}
          title={gettext("New Pattern")}
          subtitle={gettext("Fill out the form to add a new pattern")}
          form={@form}
          on_cancel={JS.push("close_modal")}
          on_submit="save"
        >
          <.input type="text" field={@form[:name]} label={gettext("Pattern Name")} />
          <.input
            type="select"
            field={@form[:starting_hands]}
            label={gettext("Starting Hands")}
            prompt={gettext("Select hand position")}
            options={Pattern.hands_options()}
          />
          <.input
            type="select"
            field={@form[:ending_hands]}
            label={gettext("Ending Hands")}
            prompt={gettext("Select hand position")}
            options={Pattern.hands_options()}
          />
          <.input type="number" field={@form[:count_num]} label={gettext("Count Number")} />
          <.input type="text" field={@form[:video_url]} label={gettext("Video URL (YouTube)")} />
          
    <!-- Child pattern selector -->
          <%= if not Enum.empty?(@child_candidates) do %>
            <div class="mt-4">
              <label class="block text-sm font-medium text-slate-300 mb-2">
                <i class="fas fa-sitemap mr-1"></i>
                {gettext("Variations (children)")}
              </label>
              <div class="max-h-48 overflow-y-auto flex flex-col gap-1 pr-1">
                <%= for candidate <- @child_candidates do %>
                  <button
                    type="button"
                    phx-click="toggle_child_selection"
                    phx-value-id={candidate.id}
                    class={[
                      "w-full text-left px-3 py-2 rounded-lg text-sm transition-all duration-150 border flex items-center justify-between",
                      if(MapSet.member?(@selected_child_ids, candidate.id),
                        do: "bg-pink-500/20 border-pink-500/50 text-pink-200",
                        else:
                          "bg-slate-700/40 border-slate-600/40 text-slate-300 hover:border-pink-500/30"
                      )
                    ]}
                  >
                    <span>{candidate.name}</span>
                    <%= if MapSet.member?(@selected_child_ids, candidate.id) do %>
                      <i class="fas fa-check text-pink-400 text-xs"></i>
                    <% end %>
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>
        </.form_modal>
      <% {:edit, _pattern} -> %>
        <.form_modal
          id="update-pattern-modal"
          show={true}
          title={gettext("Update Pattern")}
          subtitle={gettext("Edit the pattern details")}
          form={@form}
          on_cancel={JS.push("close_modal")}
          on_submit="update_pattern"
          submit_label={gettext("Update")}
          submit_hands="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700"
        >
          <.input type="text" field={@form[:name]} label={gettext("Pattern Name")} />
          <.input
            type="select"
            field={@form[:starting_hands]}
            label={gettext("Starting Hands")}
            prompt={gettext("Select hand position")}
            options={Pattern.hands_options()}
          />
          <.input
            type="select"
            field={@form[:ending_hands]}
            label={gettext("Ending Hands")}
            prompt={gettext("Select hand position")}
            options={Pattern.hands_options()}
          />
          <.input type="number" field={@form[:count_num]} label={gettext("Count Number")} />
          <.input type="text" field={@form[:video_url]} label={gettext("Video URL (YouTube)")} />
          
    <!-- Child pattern selector -->
          <%= if not Enum.empty?(@child_candidates) do %>
            <div class="mt-4">
              <label class="block text-sm font-medium text-slate-300 mb-2">
                <i class="fas fa-sitemap mr-1"></i>
                {gettext("Variations (children)")}
              </label>
              <div class="max-h-48 overflow-y-auto flex flex-col gap-1 pr-1">
                <%= for candidate <- @child_candidates do %>
                  <button
                    type="button"
                    phx-click="toggle_child_selection"
                    phx-value-id={candidate.id}
                    class={[
                      "w-full text-left px-3 py-2 rounded-lg text-sm transition-all duration-150 border flex items-center justify-between",
                      if(MapSet.member?(@selected_child_ids, candidate.id),
                        do: "bg-pink-500/20 border-pink-500/50 text-pink-200",
                        else:
                          "bg-slate-700/40 border-slate-600/40 text-slate-300 hover:border-pink-500/30"
                      )
                    ]}
                  >
                    <span>{candidate.name}</span>
                    <%= if MapSet.member?(@selected_child_ids, candidate.id) do %>
                      <i class="fas fa-check text-pink-400 text-xs"></i>
                    <% end %>
                  </button>
                <% end %>
              </div>
            </div>
          <% end %>
        </.form_modal>
      <% nil -> %>
    <% end %>
    """
  end
end
