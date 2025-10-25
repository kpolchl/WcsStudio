defmodule WcsStudioWeb.BlogLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Post
  alias WcsStudio.Comment

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

  def handle_event("save", %{"post" => %{"title" => title, "body" => body, "subject" => subject, "tags" => tags}}, socket) do
    user_id = socket.assigns.current_user.id

    case WcsStudio.Post.add(title, subject, body, tags, user_id) do
      {:ok, post} ->
        {:noreply,
          socket
          |> put_flash(:info, "Post dodany!")
          |> push_navigate(to: ~p"/blog")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def render(assigns) do
    ~H"""


    <section class="px-4 pb-16 py-4">
      <div class="mb-12 text-center">
        <h1 class="text-4xl md:text-5xl font-bold bg-gradient-to-r from-pink-500 to-purple-500 bg-clip-text text-transparent mb-4 py-2">
          <%= gettext("Blog") %>
        </h1>
        <p class="text-xl text-slate-400 max-w-2xl mx-auto">
          <%= gettext("Read and cry") %>
        </p>
      </div>

      <%= if @current_user && @current_user.role == "admin" do %>
        <button
          phx-click="open_modal"
          class="bg-purple-500 hover:bg-purple-600 text-white px-6 py-3 rounded-full shadow-lg transition-colors"
        >
          + New Post
        </button>
      <% end %>

      <div class="max-w-4xl mx-auto space-y-6">
        <%= for post <- @posts do %>
          <.post_highlight post={post} />
        <% end %>
      </div>
    </section>

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
