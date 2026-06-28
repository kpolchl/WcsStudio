defmodule WcsStudioWeb.BlogLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Post

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket,
    posts: Post.get_all(),
    title: "",
    body: "",
    user_id: nil,
    form: to_form(Ecto.Changeset.change(%WcsStudio.Post{})),
    show_modal: false
    )
    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"post" => %{"title" => title, "body" => body, "subject" => subject, "tags" => tags}}, socket) do
    user_id = socket.assigns.current_user.id

    case WcsStudio.Post.add(title, subject, body, tags, user_id) do
      {:ok, _post} ->
        {:noreply,
          socket
          |> put_flash(:info, "Post dodany!")
          |> push_navigate(to: ~p"/blog")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="mb-12 text-center">
        <h1 class="text-5xl md:text-6xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-6 py-2">
          <%= gettext("Blog") %>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          <%= gettext("Read, cry and complain") %>
        </p>
      </div>

      <!-- Add post Button (Admin Only) -->
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

      <div class="max-w-4xl mx-auto space-y-6">
        <%= for post <- @posts do %>
          <.post_highlight post={post} />
        <% end %>
      </div>


    <%= if @show_modal do %>
      <.modal id="new-post-modal" show={true} on_cancel={JS.push("close_modal")}>
        <:title>New Post</:title>
        <:subtitle>Fill out the form to add a new post</:subtitle>

        <.form for={@form} phx-submit="save">
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="text" field={@form[:subject]} label="Subject" />
          <.input type="textarea" field={@form[:body]} label="Body" />
          <.input type="text" field={@form[:tags]} label="Tags format(:tag1:tag2:tag_n:)" />
          <button class="btn"> <%= gettext("Save") %> </button>
        </.form>
      </.modal>
    <% end %>
    """
  end

end
