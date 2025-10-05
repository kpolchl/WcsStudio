defmodule WcsStudioWeb.PatternsLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Pattern
  alias WcsStudio.DanceType

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
        show_modal: false,
        show_update_modal: false,
        selected_pattern: ""
      )
    {:ok, socket
          |> allow_upload(:video,
               accept: ~w(.mp4 .mov .avi .webm),
               max_entries: 1,
               max_file_size: 100_000_000 )}
  end

  # video upload handlers
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket =
      assign(socket,
        patterns: Pattern.get_by_id_name_or_general_description(socket.assigns.dance_type_id, query),
        query: query
      )

    {:noreply, socket}
  end

  def handle_event("choose", %{"dance_type_id" => dance_type_id}, socket) do
    socket =
      assign(socket,
        patterns: Pattern.get_by_dance_type_id(String.to_integer(dance_type_id)),
        dance_type_id: String.to_integer(dance_type_id)
      )

    {:noreply, socket}
  end

  def handle_event("save", %{"pattern" => pattern_params}, socket) do
    dance_type_id = socket.assigns.dance_type_id

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
      [] -> Map.get(pattern_params, "video_url", "")
    end

    name = Map.get(pattern_params, "name")
    general_description = Map.get(pattern_params, "general_description")
    leader_description = Map.get(pattern_params, "leader_description")
    follower_description = Map.get(pattern_params, "follower_description")

    case WcsStudio.Pattern.add(dance_type_id, name, general_description, leader_description, follower_description, video_url) do
      {:ok, pattern} ->
        {:noreply,
          socket
          |> put_flash(:info, "Pattern dodany!")
          |> push_navigate(to: ~p"/patterns")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("update_pattern", %{"pattern" => pattern_params}, socket) do
    pattern = socket.assigns.selected_pattern
    dance_type_id = pattern.dance_type_id

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
      [] -> Map.get(pattern_params, "video_url", pattern.video_url)
    end

    name = Map.get(pattern_params, "name")
    general_description = Map.get(pattern_params, "general_description")
    leader_description = Map.get(pattern_params, "leader_description")
    follower_description = Map.get(pattern_params, "follower_description")

    case Pattern.update(pattern, dance_type_id, name, general_description, leader_description, follower_description, video_url) do
      {:ok, updated_pattern} ->
        updated_patterns =
          Enum.map(socket.assigns.patterns, fn p ->
            if p.id == updated_pattern.id, do: updated_pattern, else: p
          end)

        {:noreply,
          socket
          |> assign(patterns: updated_patterns, show_update_modal: false, selected_pattern: nil)
          |> put_flash(:info, "Pattern updated!")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end


  # zajebista redundancja
  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("open_update_modal", %{"id" => id}, socket) do
    pattern = Enum.find(socket.assigns.patterns, &(&1.id == String.to_integer(id)))

    {:noreply,
      assign(socket,
        show_update_modal: true,
        selected_pattern: pattern,
        form: to_form(Ecto.Changeset.change(pattern))
      )}
  end

  def handle_event("close_update_modal", _, socket) do
    {:noreply, assign(socket, show_update_modal: false, selected_pattern: nil)}
  end

  @impl true
  def handle_event("delete_pattern", %{"id" => id}, socket) do
    case Pattern.delete_pattern(id) do
      {:ok, _pattern} ->
        {:noreply,
          socket
          |> put_flash(:info, "Pattern deleted!")
          |> push_navigate(to: ~p"/patterns")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not delete pattern")}
    end
  end

  # Helper for error messages
  defp error_to_string(:too_large), do: "Video file is too large (max 100MB)"
  defp error_to_string(:too_many_files), do: "You can only upload one video at a time"
  defp error_to_string(:not_accepted), do: "Invalid video format. Please use MP4, MOV, AVI, or WebM"


  def render(assigns) do
    ~H"""
    <!-- SELECT -->
    <div class="my-8 mx-8">
      <div class="max-w-md mx-auto flex">
        <form phx-change="choose" class="relative flex items-center">
          <!-- Ikona po lewej stronie -->
          <div class="absolute left-2 flex items-center text-gray-400 pointer-events-none" flex-shrink-0>
            <img src={~p"/images/user_icon.png"} class="w-12 h-12 rounded-full bg-gray-800 justify-center flex text-white text-lg font-bold">
          </div>

          <select
            name="dance_type_id"
            class="z-10 items-center py-4 pl-12 pr-12
                   rounded-s-lg">

            <%= for dance_type <- @dance_types do %>
              <option value={dance_type.id} selected={dance_type.id == @dance_type_id}>
                <%= dance_type.name %>
              </option>
            <% end %>
          </select>

          <!-- Strzałka po prawej stronie -->
          <div class="pointer-events-none absolute inset-y-0 right-2 flex items-center text-gray-400">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </form>

        <!-- SEARCH -->
        <div class="relative w-full">
          <form phx-change="search">
            <input
              type="search"
              id="location-search"
              name="query"
              value={@query}
              class=" p-4 w-full text-gray-900 bg-gray-50 rounded-e-lg"
              placeholder="Search for pattern" />
          </form>
        </div>
      </div>

      <button phx-click="open_modal" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 border border-blue-700 rounded" >Add pattern</button>

        <%= if @show_modal do %>
        <.modal id="new-pattern-modal" show={true} on_cancel={JS.push("close_modal")}>
          <:title>New pattern</:title>
          <:subtitle>Fill out the form to add a new pattern</:subtitle>

          <.form for={@form} phx-submit="save" phx-change="validate">
            <.input type="text" field={@form[:name]} label="Title" />
            <.input type="textarea" field={@form[:general_description]} label="General Description" />
            <.input type="textarea" field={@form[:leader_description]} label="Leader description" />
            <.input type="textarea" field={@form[:follower_description]} label="Follower description" />
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

            <p class="mt-1 text-sm text-gray-500">Or enter URL below</p>
          </div>

            <.input type="text" field={@form[:video_url]} label="Video Url" />
            <button class="btn">Save</button>
          </.form>
        </.modal>
        <% end %>

    <%= if @show_update_modal do %>
    <.modal id="update-pattern-modal" show={true} on_cancel={JS.push("close_update_modal")}>
    <:title>Update Pattern</:title>
    <:subtitle>Edit the pattern details</:subtitle>

    <.form for={@form} phx-submit="update_pattern" phx-change="validate">
      <.input type="text" field={@form[:name]} label="Title" />
      <.input type="textarea" field={@form[:general_description]} label="General Description" />
      <.input type="textarea" field={@form[:leader_description]} label="Leader description" />
      <.input type="textarea" field={@form[:follower_description]} label="Follower description" />

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

        <p class="mt-1 text-sm text-gray-500">Or enter URL below</p>
      </div>

      <.input type="text" field={@form[:video_url]} label="Video Url" />
      <button class="btn">Update</button>
    </.form>
    </.modal>
    <% end %>
      <div class=" mt-4 p-4 shadow-md rounded-lg border-t-4 border-teal-400">
        <div class="columns-1 gap-16 sm:columns-2 sm:gap-8">
          <%= for pattern <- @patterns do %>
            <.pattern pattern={pattern} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end