defmodule WcsStudioWeb.LessonsLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Lesson
  alias WcsStudio.Pattern
  alias WcsStudio.Accounts.User
  alias WcsStudio.DanceType
  alias WcsStudio.Levels

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
      show_modal: false,
      show_update_modal: false,
      selected_lesson: nil,
      selected_instructor_ids: [],
      selected_pattern_ids: []
    )
    {:ok, socket
          |> allow_upload(:video,
               accept: ~w(.mp4),
               max_entries: 1,
               max_file_size: 100_000_000  # 100MB in bytes
             )}
  end

  # video_upload handlers
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    dance_type_id = socket.assigns.selected_dance_type_id
    level_id = socket.assigns.selected_level_id

    # Handle video upload
    video_url = case consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
      ext = Path.extname(entry.client_name)
      filename = "#{System.unique_integer([:positive])}#{ext}"
      dest = Path.join([:code.priv_dir(:wcs_studio), "static", "uploads", filename])

      File.mkdir_p!(Path.dirname(dest))
      File.cp!(path, dest)

      {:ok, "/uploads/#{filename}"}
    end) do
      [url | _] -> url
      [] -> Map.get(lesson_params, "lesson_vid_url", "")
    end

    title = Map.get(lesson_params, "title")
    instructor_ids = Map.get(lesson_params, "instructor_ids", [])
    pattern_ids = Map.get(lesson_params, "pattern_ids", [])
    place = Map.get(lesson_params, "place")
    date = Map.get(lesson_params, "date")

    case WcsStudio.Lesson.add(title, instructor_ids, pattern_ids, level_id, place, video_url, date, dance_type_id) do
      {:ok, lesson} ->
        {:noreply,
          socket
          |> put_flash(:info, "Lesson dodany!")
          |> push_navigate(to: ~p"/lessons")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("choose", %{"selected_dance_type_id" => selected_dance_type_id, "selected_level_id" => selected_level_id}, socket) do
    dance_type_id = String.to_integer(selected_dance_type_id)
    level_id = String.to_integer(selected_level_id)

    socket =
      assign(socket,
        lessons: Lesson.get_by_dance_type_and_level(dance_type_id, level_id),
        selected_level_id: level_id,
        selected_dance_type_id: dance_type_id,
        patterns: Pattern.get_by_dance_type_id(dance_type_id)
      )
    {:noreply, socket}
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("update_lesson", %{"lesson" => lesson_params}, socket) do
    lesson = socket.assigns.selected_lesson
    dance_type_id = socket.assigns.selected_dance_type_id
    level_id = socket.assigns.selected_level_id

    # Handle video upload
    video_url = case consume_uploaded_entries(socket, :video, fn %{path: path}, entry ->
      ext = Path.extname(entry.client_name)
      filename = "#{System.unique_integer([:positive])}#{ext}"
      dest = Path.join([:code.priv_dir(:wcs_studio), "static", "uploads", filename])

      File.mkdir_p!(Path.dirname(dest))
      File.cp!(path, dest)

      {:ok, "/uploads/#{filename}"}
    end) do
      [url | _] -> url
      [] -> Map.get(lesson_params, "lesson_vid_url", lesson.lesson_vid_url)
    end

    instructor_ids = Map.get(lesson_params, "instructor_ids", [])
    pattern_ids = Map.get(lesson_params, "pattern_ids", [])
    title = Map.get(lesson_params, "title")
    place = Map.get(lesson_params, "place")
    date = Map.get(lesson_params, "date")

    case Lesson.update(lesson, title, instructor_ids, pattern_ids, level_id, place, video_url, date, dance_type_id) do
      {:ok, updated_lesson} ->
        updated_lessons = Lesson.get_by_dance_type_and_level(dance_type_id, level_id)

        {:noreply,
          socket
          |> assign(
               lessons: updated_lessons,
               show_update_modal: false,
               selected_lesson: nil,
               selected_instructor_ids: [],
               selected_pattern_ids: []
             )
          |> put_flash(:info, "Lesson updated!")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("open_update_modal", %{"id" => id}, socket) do
    lesson = Lesson.get_by_id(id)
    instructor_ids = Enum.map(lesson.instructors, & &1.id)
    pattern_ids = Enum.map(lesson.patterns, & &1.id)
    changeset = Ecto.Changeset.change(lesson)

    {:noreply,
      assign(socket,
        show_update_modal: true,
        selected_lesson: lesson,
        selected_instructor_ids: instructor_ids,
        selected_pattern_ids: pattern_ids,
        form: to_form(changeset)
      )}
  end

  def handle_event("close_update_modal", _, socket) do
    {:noreply, assign(socket,
      show_update_modal: false,
      selected_lesson: nil,
      selected_instructor_ids: [],
      selected_pattern_ids: []
    )}
  end

  @impl true
  def handle_event("delete_lesson", %{"id" => id}, socket) do
    case Lesson.delete_lesson(id) do
      {:ok, _pattern} ->
        {:noreply,
          socket
          |> put_flash(:info, "Lesson deleted!")
          |> push_navigate(to: ~p"/lessons")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not delete lesson")}
    end
  end

  # Helper for error messages
  defp error_to_string(:too_large), do: "Video file is too large (max 100MB)"
  defp error_to_string(:too_many_files), do: "You can only upload one video at a time"
  defp error_to_string(:not_accepted), do: "Invalid video format. Please use MP4, MOV, AVI, or WebM"

  def render(assigns) do
    ~H"""
    <div class="my-8 mx-8">
      <button phx-click="open_modal" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 border border-blue-700 rounded">Add lesson</button>
      <div class="max-w-md mx-auto flex justify-center">
        <form phx-change="choose" class="relative flex items-center">
          <select name="selected_dance_type_id" class="z-10 items-center py-4 pl-12 pr-12 rounded-s-lg">
            <%= for dance_type <- @dance_types do %>
              <option value={dance_type.id} selected={dance_type.id == @selected_dance_type_id}>
                <%= dance_type.name %>
              </option>
            <% end %>
          </select>

          <select name="selected_level_id" class="z-10 items-center py-4 pl-12 pr-12 rounded-r-lg">
            <%= for level <- @levels do %>
              <option value={level.id} selected={level.id == @selected_level_id}>
                <%= level.name %>
              </option>
            <% end %>
          </select>
        </form>
      </div>

      <div class=" mt-4 p-4">
        <%= for lesson <- @lessons do %>
          <.lesson_box lesson={lesson}>
          </.lesson_box>
        <% end %>
      </div>

      <%= if @show_update_modal do %>
      <.modal id="update-lesson-modal" show={true} on_cancel={JS.push("close_update_modal")}>
        <:title class="font-bold text-8" >Update lesson</:title>
        <:subtitle class="font-bold text-8">Edit the lesson details</:subtitle>

        <.form for={@form} phx-submit="update_lesson" phx-change="validate">
          <.input type="text" field={@form[:title]} label="Title" />

      <div>
        <label class="font-bold text-8">Instructors</label>
        <div>
          <%= for instructor <- @instructors do %>
          <ul>
            <li>
            <input
            type="checkbox"
            name="lesson[instructor_ids][]"
            value={instructor.id}
            checked={instructor.id in @selected_instructor_ids}
            />
            <%= instructor.username %>
            </li>
          </ul>
          <% end %>
        </div>
      </div>

      <div>
        <label class="font-bold text-8">Patterns</label>

        <div class="flex flex-wrap gap-4  justify-left text-lg font-serif">
          <%= for pattern <- @patterns do %>
            <ul>
              <li>
              <input
              type="checkbox"
              name="lesson[pattern_ids][]"
              value={pattern.id}
              checked={pattern.id in @selected_pattern_ids}
              />
              <%= pattern.name %>
              </li>
            </ul>
          <% end %>
        </div>
      </div>
          <.input type="date" field={@form[:date]} label="Date" />

          <div class="mt-4">
            <label class="block text-sm font-semibold leading-6 text-zinc-800">
              Upload Video (Optional)
            </label>
            <.live_file_input upload={@uploads.video} class="mt-2" />

            <%= for entry <- @uploads.video.entries do %>
              <div class="mt-2 flex items-center gap-2">
                <span class="text-sm"><%= entry.client_name %></span>
                <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} class="text-red-600 text-sm">
                  Cancel
                </button>
              </div>
              <div class="mt-1 h-2 bg-gray-200 rounded">
                <div class="h-full bg-blue-500 rounded" style={"width: #{entry.progress}%"}></div>
              </div>
            <% end %>

            <%= for err <- upload_errors(@uploads.video) do %>
              <p class="mt-2 text-sm text-red-600"><%= error_to_string(err) %></p>
            <% end %>

          </div>

          <.input type="select" field={@form[:place]}  label="Place" options={[{"Buma Square Business Park, Wadowicka 6", "Buma Square Business Park, Wadowicka 6"}]}/>
          <button class="btn">Save</button>
        </.form>
      </.modal>
      <% end %>

      <%= if @show_modal do %>
      <.modal id="new-lesson-modal" show={true} on_cancel={JS.push("close_modal")}>
        <:title class="font-bold text-8" >New lesson</:title>
        <:subtitle class="font-bold text-8">Fill out the form to add a new lesson</:subtitle>

        <.form for={@form} phx-submit="save" phx-change="validate">
          <.input type="text" field={@form[:title]} label="Title" />
      <div>
        <label class="font-bold text-8">Instructors</label>
        <div>
          <%= for instructor <- @instructors do %>
          <ul>
            <li>
            <input
              type="checkbox"
              name="lesson[instructor_ids][]"
              value={instructor.id}
              checked={instructor.id in (@form[:instructor_ids].value || [])}
            />
            <%= instructor.username %>
            </li>
          </ul>
          <% end %>
        </div>
      </div>

      <div>
        <label class="font-bold text-8">Patterns</label>

        <div class="flex flex-wrap gap-4  justify-left text-lg font-serif">
          <%= for pattern <- @patterns do %>
            <ul>
              <li>
              <input
                type="checkbox"
                name="lesson[pattern_ids][]"
                value={pattern.id}
                checked={pattern.id in (@form[:pattern_ids].value || [])}
              />
              <%= pattern.name %>
              </li>
            </ul>
          <% end %>
        </div>
      </div>
          <.input type="date" field={@form[:date]} label="Date" />

          <div class="mt-4">
            <label class="block text-sm font-semibold leading-6 text-zinc-800">
              Upload Video (Optional)
            </label>
            <.live_file_input upload={@uploads.video} class="mt-2" />

            <%= for entry <- @uploads.video.entries do %>
              <div class="mt-2 flex items-center gap-2">
                <span class="text-sm"><%= entry.client_name %></span>
                <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} class="text-red-600 text-sm">
                  Cancel
                </button>
              </div>
              <div class="mt-1 h-2 bg-gray-200 rounded">
                <div class="h-full bg-blue-500 rounded" style={"width: #{entry.progress}%"}></div>
              </div>
            <% end %>

            <%= for err <- upload_errors(@uploads.video) do %>
              <p class="mt-2 text-sm text-red-600"><%= error_to_string(err) %></p>
            <% end %>

          </div>
          <.input type="select" field={@form[:place]}  label="Place" options={[{"Buma Square Business Park, Wadowicka 6", "Buma Square Business Park, Wadowicka 6"}]}/>
          <button class="btn">Save</button>
        </.form>
      </.modal>
      <% end %>
    </div>
    """
  end
end