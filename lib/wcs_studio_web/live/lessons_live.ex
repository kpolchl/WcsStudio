defmodule WcsStudioWeb.LessonsLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Lesson
  alias WcsStudio.Pattern
  alias WcsStudio.Accounts.User
  alias WcsStudio.DanceType
  alias WcsStudio.Levels
  alias WcsStudio.VideoProcess

  @impl true
  def mount(_params, _session, socket) do
    first_lesson = Lesson.get_first()

    socket = assign(socket,
      dance_types: DanceType.get_all(),
      selected_dance_type_id: first_lesson.dance_type_id,
      selected_level_id: first_lesson.level_id,
      lessons: Lesson.get_by_dance_type_and_level(first_lesson.dance_type_id, first_lesson.level_id),
      levels: Levels.get_all(),
      instructors: User.get_instructors(),
      patterns: Pattern.get_by_dance_type_id(first_lesson.dance_type_id),
      form: to_form(Ecto.Changeset.change(%WcsStudio.Lesson{})),
      modal_state: nil,
      expanded_lesson_id: nil
    )
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    # Build a map of lesson_id => true for lessons the user attended
    attended_map = case socket.assigns[:current_user] do
      nil ->
        %{}
      current_user ->
        user_lessons = WcsStudio.UserLesson.get_user_lessons(current_user.id)
        Enum.reduce(user_lessons, %{}, fn user_lesson, acc ->
          Map.put(acc, user_lesson.lesson_id, true)
        end)
    end

    {:noreply,
      socket
      |> assign(:attended_map, attended_map)
      |> assign(:expanded_lesson_id, nil)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    dance_type_id = socket.assigns.selected_dance_type_id
    level_id = socket.assigns.selected_level_id

    lesson_vid_url = lesson_params
                     |> Map.get("lesson_vid_url", "")
                     |> VideoProcess.parse_youtube_url()
    title = Map.get(lesson_params, "title")
    instructor_ids = Map.get(lesson_params, "instructor_ids", [])
    pattern_ids = Map.get(lesson_params, "pattern_ids", [])
    place = Map.get(lesson_params, "place")
    date = Map.get(lesson_params, "date")

    case WcsStudio.Lesson.add(title, instructor_ids, pattern_ids, level_id, place, lesson_vid_url, date, dance_type_id) do
      {:ok, _lesson} ->
        {:noreply,
          socket
          |> assign(modal_state: nil)
          |> put_flash(:success, "Lesson created successfully!")
          |> push_navigate(to: ~p"/admin/lessons")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket,
      modal_state: :create,
      form: to_form(Ecto.Changeset.change(%WcsStudio.Lesson{}))
    )}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_state: nil)}
  end

  @impl true
  def handle_event("update_lesson", %{"lesson" => lesson_params}, socket) do
    case socket.assigns.modal_state do
      {:edit, lesson, _instructor_ids, _pattern_ids} ->
        dance_type_id = socket.assigns.selected_dance_type_id
        level_id = socket.assigns.selected_level_id

        lesson_vid_url = lesson_params
                         |> Map.get("lesson_vid_url", "")
                         |> VideoProcess.parse_youtube_url()
        instructor_ids = Map.get(lesson_params, "instructor_ids", [])
        pattern_ids = Map.get(lesson_params, "pattern_ids", [])
        title = Map.get(lesson_params, "title")
        place = Map.get(lesson_params, "place")
        date = Map.get(lesson_params, "date")

        case Lesson.update(lesson, title, instructor_ids, pattern_ids, level_id, place, lesson_vid_url, date, dance_type_id) do
          {:ok, _updated_lesson} ->
            updated_lessons = Lesson.get_by_dance_type_and_level(dance_type_id, level_id)

            {:noreply,
              socket
              |> assign(lessons: updated_lessons, modal_state: nil)
              |> put_flash(:success, "Lesson updated successfully!")}

          {:error, changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_update_modal", %{"id" => id}, socket) do
    lesson = Lesson.get_by_id(id)
    instructor_ids = Enum.map(lesson.instructors, & &1.id)
    pattern_ids = Enum.map(lesson.patterns, & &1.id)
    changeset = Ecto.Changeset.change(lesson)

    {:noreply,
      assign(socket,
        modal_state: {:edit, lesson, instructor_ids, pattern_ids},
        form: to_form(changeset)
      )}
  end

  @impl true
  def handle_event("delete_lesson", %{"id" => id}, socket) do
    case Lesson.delete_lesson(id) do
      {:ok, _pattern} ->
        {:noreply,
          socket
          |> put_flash(:success, "Lesson deleted successfully!")
          |> push_navigate(to: ~p"/admin/lessons")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not delete lesson")}
    end
  end

  @impl true
  def handle_event("toggle_lesson", %{"id" => id}, socket) do
    id = String.to_integer(id)
    new_id = if socket.assigns.expanded_lesson_id == id, do: nil, else: id
    {:noreply, assign(socket, :expanded_lesson_id, new_id)}
  end

  @impl true
  def handle_event("choose_dance_type", %{"dance_type_id" => dance_type_id}, socket) do
    dance_type_id = String.to_integer(dance_type_id)
    level_id = socket.assigns.selected_level_id

    socket =
      assign(socket,
        lessons: Lesson.get_by_dance_type_and_level(dance_type_id, level_id),
        selected_dance_type_id: dance_type_id,
        patterns: Pattern.get_by_dance_type_id(dance_type_id)
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("choose_level", %{"level_id" => level_id}, socket) do
    level_id = String.to_integer(level_id)
    dance_type_id = socket.assigns.selected_dance_type_id

    socket =
      assign(socket,
        lessons: Lesson.get_by_dance_type_and_level(dance_type_id, level_id),
        selected_level_id: level_id
      )
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_attendance", %{"lesson_id" => lesson_id, "user_id" => user_id}, socket) do
    lesson_id_int = String.to_integer(lesson_id)
    user_id_int = String.to_integer(user_id)

    # Check if user attended this lesson (UserLesson record exists)
    currently_attended = Map.get(socket.assigns.attended_map, lesson_id_int, false)

    updated_attended_map = if currently_attended do
      # User attended, so remove the UserLesson record
      case WcsStudio.UserLesson.get_user_lesson(user_id_int, lesson_id_int) do
        nil ->
          socket.assigns.attended_map
        user_lesson ->
          WcsStudio.UserLesson.delete(user_lesson)
          Map.delete(socket.assigns.attended_map, lesson_id_int)
      end
    else
      # User didn't attend, so create UserLesson record
      WcsStudio.UserLesson.add(user_id_int, lesson_id_int)
      Map.put(socket.assigns.attended_map, lesson_id_int, true)
    end

    {:noreply,
      socket
      |> assign(:attended_map, updated_attended_map)
      |> put_flash(:info, if(currently_attended, do: "Attendance removed!", else: "Attendance marked!"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <!-- Header -->
      <div class="mb-12 text-center px-4">
        <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
          <%= gettext("Lessons") %>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          <%= gettext("Browse and track your dance lessons by type and level") %>
        </p>
      </div>

      <!-- Add Lesson Button (Admin Only) -->
      <%= if @current_user && @current_user.role == "admin" do %>
        <div class="max-w-2xl mx-8 my-8">
          <button
            phx-click="open_modal"
            class="w-full sm:w-auto bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600 text-white font-semibold py-3 px-6 rounded-lg shadow-lg hover:shadow-xl transition-all duration-300 flex items-center justify-center gap-2"
          >
            <i class="fas fa-plus"></i>
            <span><%= gettext("Add New Lesson") %></span>
          </button>
        </div>
      <% end %>

      <!-- Dance Type Filters -->
      <div class="flex flex-wrap justify-center gap-4 mt-8">
        <%= for dance_type <- @dance_types do %>
          <button
            phx-click="choose_dance_type"
            phx-value-dance_type_id={dance_type.id}
            class={[
              "px-6 py-2 rounded-lg font-medium transition-all duration-300",
              if(@selected_dance_type_id == dance_type.id,
                do: "bg-gradient-to-r from-pink-500 to-purple-500 text-white hover:shadow-lg hover:shadow-pink-500/25",
                else: "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50")
            ]}
          >
            <%= DanceType.get_name(dance_type, @locale) %>
          </button>
        <% end %>
      </div>

      <!-- Level Filters -->
      <div class="flex flex-wrap justify-center gap-4 mt-4">
        <%= for level <- @levels do %>
          <button
            phx-click="choose_level"
            phx-value-level_id={level.id}
            class={[
              "px-6 py-2 rounded-lg font-medium transition-all duration-300",
              if(@selected_level_id == level.id,
                do: "bg-gradient-to-r from-blue-500 to-cyan-500 text-white hover:shadow-lg hover:shadow-blue-500/25",
                else: "bg-slate-800/50 hover:bg-slate-700/50 text-slate-300 border border-slate-700/50")
            ]}
          >
            <%= level.name %>
          </button>
        <% end %>
      </div>

      <!-- Lessons List -->
       <div class="mt-4 lg:p-4  flex flex-col items-center ">
        <%= for lesson <- @lessons do %>
          <.lesson_box
            lesson={lesson}
            current_user={@current_user}
            expanded_lesson_id={@expanded_lesson_id}
            attended={Map.get(@attended_map, lesson.id, false)}
            locale={@locale}
          />
          <%= if @current_user && @current_user.role == "admin" do %>
            <.confirm_modal
              id={"confirm-delete-lesson-#{lesson.id}"}
              title={gettext("Delete Lesson?")}
              message={gettext("Are you sure you want to delete '%{title}'? This action cannot be undone and will remove all associated data.", title: lesson.title)}
              confirm_event="delete_lesson"
              confirm_value={lesson.id}
            />
          <% end %>
        <% end %>
      </div>

      <!-- Empty State -->
      <%= if Enum.empty?(@lessons) do %>
        <div class="text-center py-16">
          <div class="w-24 h-24 mx-auto mb-4 rounded-full bg-slate-800/50 flex items-center justify-center">
            <i class="fas fa-chalkboard-teacher text-3xl text-slate-500"></i>
          </div>
          <h3 class="text-xl font-semibold text-slate-400 mb-2"><%= gettext("No lessons found") %></h3>
          <p class="text-slate-500"><%= gettext("Try selecting a different dance type or level") %></p>
        </div>
      <% end %>

      <!-- Modals -->
      <%= case @modal_state do %>
        <% :create -> %>
          <.form_modal
            id="new-lesson-modal"
            show={true}
            title={gettext("New Lesson")}
            subtitle={gettext("Fill out the form to add a new lesson")}
            form={@form}
            on_cancel={JS.push("close_modal")}
            on_submit="save"
          >
            <.input type="text" field={@form[:title]} label={gettext("Title")} />

            <!-- Instructors -->
            <div class="space-y-2">
              <label class="block text-sm font-semibold text-slate-800"><%= gettext("Instructors") %></label>
              <div class="bg-slate-550 rounded-lg p-4 border border-slate-600 space-y-2 max-h-48 overflow-y-auto">
                <%= for instructor <- @instructors do %>
                  <label class="flex items-center gap-3 p-2 hover:bg-slate-700/50 rounded-lg cursor-pointer transition-colors">
                    <input
                      type="checkbox"
                      name="lesson[instructor_ids][]"
                      value={instructor.id}
                      checked={instructor.id in (@form[:instructor_ids].value || [])}
                      class="rounded border-slate-600 bg-slate-800/50 text-pink-500 focus:ring-2 focus:ring-pink-500 focus:ring-opacity-20 transition-all duration-300"
                    />
                    <span class="text-slate-200"><%= instructor.username %></span>
                  </label>
                <% end %>
              </div>
            </div>

            <!-- Patterns -->
            <div class="space-y-2">
              <label class="block text-sm font-semibold text-slate-800"><%= gettext("Patterns") %></label>
              <div class="bg-slate-550 rounded-lg p-4 border border-slate-600 space-y-2 max-h-48 overflow-y-auto">
                <%= for pattern <- @patterns do %>
                  <label class="flex items-center gap-3 p-2 hover:bg-slate-700/50 rounded-lg cursor-pointer transition-colors">
                    <input
                      type="checkbox"
                      name="lesson[pattern_ids][]"
                      value={pattern.id}
                      checked={pattern.id in (@form[:pattern_ids].value || [])}
                      class="rounded border-slate-600 bg-slate-800/50 text-pink-500 focus:ring-2 focus:ring-pink-500 focus:ring-opacity-20 transition-all duration-300"
                    />
                    <span class="text-slate-200"><%= pattern.name %></span>
                  </label>
                <% end %>
              </div>
            </div>

            <.input type="date" field={@form[:date]} label={gettext("Date")} />
            <.input type="select" field={@form[:place]} label={gettext("Place")} options={[{"Buma Square Business Park, Wadowicka 6", "Buma Square Business Park, Wadowicka 6"}]} />
            <.input type="text" field={@form[:lesson_vid_url]} label={gettext("Video URL (YouTube)")} />
          </.form_modal>

        <% {:edit, _lesson, instructor_ids, pattern_ids} -> %>
          <.form_modal
            id="update-lesson-modal"
            show={true}
            title={gettext("Update Lesson")}
            subtitle={gettext("Edit the lesson details")}
            form={@form}
            on_cancel={JS.push("close_modal")}
            on_submit="update_lesson"
            submit_label={gettext("Update")}
            submit_class="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700"
          >
            <.input type="text" field={@form[:title]} label={gettext("Title")} />

            <!-- Instructors -->
            <div class="space-y-2">
              <label class="block text-sm font-semibold text-slate-800"><%= gettext("Instructors") %></label>
                <div class="bg-slate-550 rounded-lg p-4 border border-slate-600 space-y-2 max-h-48 overflow-y-auto">
                  <%= for instructor <- @instructors do %>
                    <label class="flex items-center gap-3 p-2 hover:bg-slate-700/50 rounded-lg cursor-pointer transition-colors">
                      <input
                        type="checkbox"
                        name="lesson[instructor_ids][]"
                        value={instructor.id}
                        checked={instructor.id in instructor_ids}
                        class="rounded border-slate-600 bg-slate-800/50 text-pink-500 focus:ring-2 focus:ring-pink-500 focus:ring-opacity-20 transition-all duration-300"
                      />
                      <span class="text-slate-200"><%= instructor.username %></span>
                    </label>
                  <% end %>
                </div>
            </div>

            <!-- Patterns -->
            <div class="space-y-2">
              <label class="block text-sm font-semibold text-slate-800"><%= gettext("Patterns") %></label>
              <div class="bg-slate-550 rounded-lg p-4 border border-slate-600 space-y-2 max-h-48 overflow-y-auto">
                <%= for pattern <- @patterns do %>
                  <label class="flex items-center gap-3 p-2 hover:bg-slate-700/50 rounded-lg cursor-pointer transition-colors">
                    <input
                      type="checkbox"
                      name="lesson[pattern_ids][]"
                      value={pattern.id}
                      checked={pattern.id in pattern_ids}
                      class="rounded border-slate-600 bg-slate-800/50 text-pink-500 focus:ring-2 focus:ring-pink-500 focus:ring-opacity-20 transition-all duration-300"
                    />
                    <span class="text-slate-200"><%= pattern.name %></span>
                  </label>
                <% end %>
              </div>
            </div>

            <.input type="date" field={@form[:date]} label={gettext("Date")} />
            <.input type="select" field={@form[:place]} label={gettext("Place")} options={[{"Buma Square Business Park, Wadowicka 6", "Buma Square Business Park, Wadowicka 6"}]} />
            <.input type="text" field={@form[:lesson_vid_url]} label={gettext("Video URL (YouTube)")} />
          </.form_modal>

        <% nil -> %>
      <% end %>
    """
  end
end