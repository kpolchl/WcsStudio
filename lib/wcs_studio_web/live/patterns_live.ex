defmodule WcsStudioWeb.PatternsLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Pattern
  alias WcsStudio.DanceType
  alias WcsStudio.UserPattern
  alias WcsStudio.VideoProcess

  @impl true
  def mount(_params, _session, socket) do
    first_dance_type = DanceType.get_first()

    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        dance_type_id: first_dance_type.id,
        selected_dance_type: DanceType.get_by_id(first_dance_type.id),
        patterns: Pattern.get_by_dance_type_id(first_dance_type.id),
        query: "",
        form: to_form(Ecto.Changeset.change(%WcsStudio.Pattern{})),
        modal_state: nil,
        expanded_pattern_id: nil,
        dropdown_open: false,
        ghost_text: "Search patterns"
      )
    {:ok, socket
          |> allow_upload(:video,
               accept: ~w(.mp4 .mov .avi .webm),
               max_entries: 1,
               max_file_size: 100_000_000 )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    status_map = case socket.assigns[:current_user] do
      nil ->
        %{}
      current_user ->
        user_patterns = WcsStudio.UserPattern.get_user_patterns(current_user.id)
        Enum.reduce(user_patterns, %{}, fn up, acc ->
          Map.put(acc, up.pattern_id, up.status)
        end)
    end

    {:noreply,
      socket
      |> assign(:status_map, status_map)
      |> assign(:expanded_pattern_id, nil)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_pattern", %{"id" => id}, socket) do
    id = String.to_integer(id)
    new_id = if socket.assigns.expanded_pattern_id == id, do: nil, else: id
    {:noreply, assign(socket, :expanded_pattern_id, new_id)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    new_patterns = Pattern.get_by_id_name_or_general_description(
      socket.assigns.dance_type_id,
      query
    )

    ghost_text = calculate_ghost_text(query, new_patterns)

    {:noreply, assign(socket,
      patterns: new_patterns,
      query: query,
      ghost_text: ghost_text
    )}
  end

  defp calculate_ghost_text("", _patterns), do: "Search patterns"

  defp calculate_ghost_text(query, patterns) do
    query_lower = String.downcase(String.trim(query))

    patterns
    |> Enum.map(& &1.name)
    |> Enum.filter(&(String.starts_with?(String.downcase(&1), query_lower)))
    |> Enum.sort_by(&{String.length(&1), &1})
    |> List.first()
    |> filter_exact_match(query_lower)
  end

  defp filter_exact_match(nil, _query), do: ""
  defp filter_exact_match(suggestion, query) do
    if String.downcase(suggestion) == query, do: "", else: suggestion
  end

  @impl true
  def handle_event("save", %{"pattern" => pattern_params}, socket) do
    video_url = pattern_params
                |> Map.get("video_url", "")
                |> VideoProcess.parse_youtube_url()

    attrs = %{
      dance_type_id: socket.assigns.dance_type_id,
      name: Map.get(pattern_params, "name"),
      general_description_en: Map.get(pattern_params, "general_description_en"),
      leader_description_en: Map.get(pattern_params, "leader_description_en"),
      follower_description_en: Map.get(pattern_params, "follower_description_en"),
      general_description_pl: Map.get(pattern_params, "general_description_pl"),
      leader_description_pl: Map.get(pattern_params, "leader_description_pl"),
      follower_description_pl: Map.get(pattern_params, "follower_description_pl"),
      video_url: video_url
    }

    case Pattern.add(attrs) do
      {:ok, _pattern} ->
        {:noreply,
          socket
          |> assign(modal_state: nil)
          |> put_flash(:success, "Pattern created successfully!")
          |> push_navigate(to: ~p"/patterns")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("update_pattern", %{"pattern" => pattern_params}, socket) do
    case socket.assigns.modal_state do
      {:edit, pattern} ->
        video_url = pattern_params
                    |> Map.get("video_url", "")
                    |> VideoProcess.parse_youtube_url()

        attrs = %{
          dance_type_id: pattern.dance_type_id,
          name: Map.get(pattern_params, "name"),
          general_description_en: Map.get(pattern_params, "general_description_en"),
          leader_description_en: Map.get(pattern_params, "leader_description_en"),
          follower_description_en: Map.get(pattern_params, "follower_description_en"),
          general_description_pl: Map.get(pattern_params, "general_description_pl"),
          leader_description_pl: Map.get(pattern_params, "leader_description_pl"),
          follower_description_pl: Map.get(pattern_params, "follower_description_pl"),
          video_url: video_url
        }

        case Pattern.update(pattern, attrs) do
          {:ok, _updated_pattern} ->
            updated_patterns = Pattern.get_by_dance_type_id(socket.assigns.dance_type_id)

            {:noreply,
              socket
              |> assign(patterns: updated_patterns, modal_state: nil)
              |> put_flash(:success, "Pattern updated successfully!")}

          {:error, changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket,
      modal_state: :create,
      form: to_form(Ecto.Changeset.change(%WcsStudio.Pattern{}))
    )}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_state: nil)}
  end

  @impl true
  def handle_event("open_update_modal", %{"id" => id}, socket) do
    pattern = Enum.find(socket.assigns.patterns, &(&1.id == String.to_integer(id)))

    {:noreply,
      assign(socket,
        modal_state: {:edit, pattern},
        form: to_form(Ecto.Changeset.change(pattern))
      )}
  end

  @impl true
  def handle_event("delete_pattern", %{"id" => id}, socket) do
    case Pattern.delete_pattern(id) do
      {:ok, _pattern} ->
        {:noreply,
          socket
          |> put_flash(:success, "Pattern deleted successfully!")
          |> push_navigate(to: ~p"/patterns")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not delete pattern")}
    end
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
  def handle_event("update_status", %{"pattern_id" => pattern_id, "user_id" => user_id, "status" => status}, socket) do
    pattern_id_int = String.to_integer(pattern_id)

    new_status = case status do
      "not_started" -> "in_progress"
      "in_progress" -> "learned"
      "learned" -> "learned"
    end

    case UserPattern.get_user_pattern(user_id, pattern_id) do
      nil ->
        UserPattern.add(pattern_id, user_id, new_status)
      user_pattern ->
        UserPattern.update_status(user_pattern, pattern_id, user_id, new_status)
    end

    updated_status_map = Map.put(socket.assigns.status_map, pattern_id_int, new_status)

    {:noreply,
      socket
      |> assign(:status_map, updated_status_map)
      |> put_flash(:info, "Status updated to #{new_status}!")}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <!-- Header Section -->
      <div class="mb-12 text-center px-4">
        <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
          <%= gettext("Steps") %>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          <%= gettext("Explore our collection of dance moves with step-by-step instructions, video demonstrations, and detailed breakdowns for leaders and followers.") %>
        </p>
      </div>

      <!-- Add Pattern Button (Admin Only) -->
      <%= if @current_user && @current_user.role == "admin" do %>
        <div class="w-full max-w-2xl mx-auto px-4 mb-8">
          <button
            phx-click="open_modal"
            class="w-full sm:w-auto bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600 text-white font-semibold py-3 px-6 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2">
            <i class="fas fa-plus"></i>
            <span><%= gettext("Add New Pattern") %></span>
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

          <!-- Search Input -->
          <div class="flex-1 relative">
            <form phx-change="search" class="h-full">
              <div class="relative h-full">
                <div class="pl-1 absolute left-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                  <i class="fas fa-search text-slate-400 text-sm"></i>
                </div>
                <div class="relative">
                <!-- Real input -->
                  <input
                  type="search"
                  name="query"
                  value={@query}
                  class="relative z-10 w-full h-full
                         pl-10 pr-8 py-3
                         bg-slate-700/50 text-slate-200
                         border border-slate-600/50
                         rounded-lg
                         focus:outline-none focus:ring-1 focus:ring-blue-500"

                />

                <!-- Ghost text overlay -->
                  <%= if @ghost_text != "" && @query != "" do %>
                    <div class="absolute inset-0 z-0 flex items-center pointer-events-none pl-10 pr-8">
                      <div class="text-slate-200 opacity-0 select-none"><%= @query %></div>
                      <div class="text-slate-500/40"><%= String.slice(@ghost_text, String.length(@query), String.length(@ghost_text)) %></div>
                    </div>
                  <% end %>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>

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
            <.input type="textarea" field={@form[:general_description_en]} label={gettext("General Description EN")} />
            <.input type="textarea" field={@form[:leader_description_en]} label={gettext("Leader Description EN")} />
            <.input type="textarea" field={@form[:follower_description_en]} label={gettext("Follower Description EN")} />
            <.input type="textarea" field={@form[:general_description_pl]} label={gettext("General Description PL")} />
            <.input type="textarea" field={@form[:leader_description_pl]} label={gettext("Leader Description PL")} />
            <.input type="textarea" field={@form[:follower_description_pl]} label={gettext("Follower Description PL")} />
            <.input type="text" field={@form[:video_url]} label={gettext("Video URL (YouTube)")} />
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
            submit_class="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700"
          >
            <.input type="text" field={@form[:name]} label={gettext("Pattern Name")} />
            <.input type="textarea" field={@form[:general_description_en]} label={gettext("General Description EN")} />
            <.input type="textarea" field={@form[:leader_description_en]} label={gettext("Leader Description EN")} />
            <.input type="textarea" field={@form[:follower_description_en]} label={gettext("Follower Description EN")} />
            <.input type="textarea" field={@form[:general_description_pl]} label={gettext("General Description PL")} />
            <.input type="textarea" field={@form[:leader_description_pl]} label={gettext("Leader Description PL")} />
            <.input type="textarea" field={@form[:follower_description_pl]} label={gettext("Follower Description PL")} />
            <.input type="text" field={@form[:video_url]} label={gettext("Video URL (YouTube)")} />
          </.form_modal>

        <% nil -> %>
      <% end %>

      <!-- Patterns Grid -->
      <div class="mt-4 lg:p-4">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <%= for pattern <- @patterns do %>
            <.pattern
              pattern={pattern}
              current_user={@current_user}
              expanded_pattern_id={@expanded_pattern_id}
              status={@status_map[pattern.id]}
              locale={@locale}
            />
            <%= if @current_user && @current_user.role == "admin" do %>
              <.confirm_modal
                id={"confirm-delete-pattern-#{pattern.id}"}
                title={gettext("Delete Pattern?")}
                message={gettext("Are you sure you want to delete '%{name}'? This action cannot be undone and will remove all associated data.", name: pattern.name)}
                confirm_event="delete_pattern"
                confirm_value={pattern.id}
              />
            <% end %>
          <% end %>
        </div>
      </div>

      <!-- Empty State -->
      <%= if Enum.empty?(@patterns) do %>
        <div class="text-center py-16">
          <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-slate-800/50 flex items-center justify-center">
            <i class="fas fa-music text-3xl text-slate-500"></i>
          </div>
          <h3 class="text-xl font-semibold text-slate-400 mb-2"><%= gettext("No patterns found") %></h3>
          <p class="text-slate-500"><%= gettext("Try selecting a different filter or adjusting your search") %></p>
        </div>
      <% end %>
    """
  end
end