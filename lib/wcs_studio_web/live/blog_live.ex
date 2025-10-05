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

  def handle_event("save", %{"post" => %{"title" => title, "body" => body}}, socket) do
    user_id = socket.assigns.current_user.id

    case WcsStudio.Post.add(title, body, user_id) do
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
    <button phx-click="open_modal">Add Post</button>

    <%= if @show_modal do %>
    <.modal id="new-post-modal" show={true} on_cancel={JS.push("close_modal")}>
      <:title>New Post</:title>
      <:subtitle>Fill out the form to add a new post</:subtitle>

      <.form for={@form} phx-submit="save">
        <.input type="text" field={@form[:title]} label="Title" />
        <.input type="textarea" field={@form[:body]} label="Body" />
        <button class="btn">Save</button>
      </.form>
    </.modal>
    <% end %>

    <%= for post <- @posts do %>
    <.post post={post}>

    </.post>
    <% end %>
    """
  end


end
