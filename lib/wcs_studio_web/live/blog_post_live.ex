defmodule WcsStudioWeb.BlogPostLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Post
  alias WcsStudio.Comment

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    post = Post.get_post_by_id(id)

    if post do
      socket = assign(socket,
        post: post,
        comments: post.comments,
        new_comment: "",
        editing_post: false,  # Add editing state
        edit_form: to_form(Ecto.Changeset.change(post))  # Add edit form
      )
      {:ok, socket}
    else
      {:ok,
        socket
        |> put_flash(:error, "Post not found")
        |> push_navigate(to: ~p"/blog")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    post = Post.get_post_by_id(id)
    {:noreply, assign(socket, post: post)}
  end

  @impl true
  def handle_event("add_comment", %{"comment" => %{"body" => body}}, socket) do
    user_id = socket.assigns.current_user.id
    post_id = socket.assigns.post.id

    case Comment.add(body, user_id, post_id) do
      {:ok, _comment} ->
        updated_post = Post.get_post_by_id(post_id)
        {:noreply, assign(socket, post: updated_post, new_comment: "")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add comment")}
    end
  end

  @impl true
  # New events for post editing
  def handle_event("edit_post", _, socket) do
    changeset = Ecto.Changeset.change(socket.assigns.post)
    {:noreply, assign(socket, editing_post: true, edit_form: to_form(changeset))}
  end

  @impl true
  def handle_event("update_post", %{"post" => post_params}, socket) do
    case Post.update_post(socket.assigns.post.id, post_params) do
      {:ok, updated_post} ->
        {:noreply,
          socket
          |> put_flash(:info, "Post updated successfully!")
          |> assign(
               post: updated_post,
               editing_post: false,
               edit_form: to_form(Ecto.Changeset.change(updated_post))
             )}

      {:error, changeset} ->
        {:noreply, assign(socket, edit_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing_post: false)}
  end

  @impl true
  def handle_event("delete_post", _, socket) do
    case Post.delete_post(socket.assigns.post) do
      {:ok, _} ->
        {:noreply,
          socket
          |> put_flash(:info, "Post deleted successfully!")
          |> push_navigate(to: ~p"/blog")}

      {:error, _} ->
        {:noreply,
          socket
          |> put_flash(:error, "Failed to delete post!")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <!-- Back Navigation -->
      <div class="max-w-4xl mx-auto px-4 pt-8">
        <div class="flex justify-between items-center">
          <.link
            navigate={~p"/blog"}
            class="inline-flex items-center gap-2 text-purple-300 hover:text-purple-200 transition-colors group"
          >
            <i class="fas fa-arrow-left group-hover:-translate-x-1 transition-transform"></i>
            <span> <%= gettext("Back to Blog")%> </span>
          </.link>

          <!-- Admin Actions -->
          <%= if @current_user && @current_user.role == "admin" && !@editing_post do %>
            <div class="flex gap-2">
              <button
                phx-click="edit_post"
                class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg transition-colors flex items-center gap-2"
              >
                <i class="fas fa-edit"></i>
                <%= gettext("Edit Post") %>
              </button>
              <button
                phx-click="delete_post"
                class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg transition-colors flex items-center gap-2"
                onclick="return confirm('Are you sure you want to delete this post?');"
              >
                <i class="fas fa-trash"></i>
                <%= gettext("Delete Post") %>
              </button>
            </div>
          <% end %>
        </div>
      </div>

      <!-- Article Container -->
      <article class="max-w-4xl mx-auto px-4 py-12">
        <%= if @editing_post do %>
          <!-- Edit Post Form -->
          <div class="bg-slate-800/30 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-8">
            <h2 class="text-3xl font-bold text-white mb-6">Edit Post</h2>

            <.form for={@edit_form} phx-submit="update_post">
              <div class="space-y-4">
                <.input
                  type="text"
                  field={@edit_form[:title]}
                  label="Title"
                  class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />

                <.input
                  type="text"
                  field={@edit_form[:subject]}
                  label="Subject"
                  class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />

                <.input
                  type="textarea"
                  field={@edit_form[:body]}
                  label="Body"
                  class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  rows="10"
                />

                <.input
                  type="text"
                  field={@edit_form[:tags]}
                  label="Tags (format: :tag1:tag2:tag_n:)"
                  class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                />
              </div>

              <div class="flex gap-3 mt-6">
                <button
                  type="submit"
                  class="px-6 py-3 bg-gradient-to-r from-green-500 to-blue-500 text-white font-medium rounded-xl hover:shadow-lg hover:shadow-green-500/50 transition-all duration-300"
                >
                  <i class="fas fa-save mr-2"></i>
                  <%= gettext("Update Post") %>
                </button>

                <button
                  type="button"
                  phx-click="cancel_edit"
                  class="px-6 py-3 bg-slate-600 hover:bg-slate-700 text-white font-medium rounded-xl transition-colors"
                >
                  <i class="fas fa-times mr-2"></i>
                  <%= gettext("Cancel") %>
                </button>
              </div>
            </.form>
          </div>
        <% else %>
          <!-- Original Post Display -->
          <!-- Article Header -->
          <header class="mb-12">
            <!-- Meta Information -->
            <div class="flex items-center gap-3 mb-6">
              <span class="px-4 py-1.5 rounded-full text-sm bg-gradient-to-r from-purple-500 to-pink-500 text-white font-medium">
                <%= @post.subject%>
              </span>
              <span class="text-slate-400">
                <%= if @post.inserted_at do %>
                  <%= Calendar.strftime(@post.inserted_at, "%B %d, %Y") %>
                <% else %>
                  <%= gettext("Unknown date")%>
                <% end %>
              </span>
              <span class="text-slate-400">•</span>
              <span class="text-slate-400"><%= Post.estimate_read_time(@post.body) %></span>
            </div>

            <!-- Title -->
            <h1 class="text-5xl font-bold text-white mb-6 leading-tight">
              <%= @post.title %>
            </h1>

            <!-- Author Info -->
            <div class="flex items-center gap-4">
              <img
                src={@post.user.profile_pic_url || "/images/default-avatar.png"}
                class="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 p-0.5"
                alt={@post.user.username}
              >
              <div>
                <p class="font-semibold text-white text-lg"><%= @post.user.username %></p>
                <p class="text-slate-400"> <%= @post.user.role %></p>
              </div>
            </div>
          </header>

          <!-- Article Content -->
          <div class="prose prose-invert prose-lg max-w-none mb-16">
            <div class="bg-slate-800/30 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-8 text-slate-200 leading-relaxed">
              <%= raw(format_content(@post.body)) %>
            </div>
          </div>

          <!-- Article Footer / Tags -->
          <div class="border-t border-slate-700 pt-8 mb-12">
            <div class="flex items-center gap-3">
              <span class="text-slate-400">Tags:</span>
              <%= for tag <- Post.parse_tags(@post.tags) do %>
                <span class="px-3 py-1 rounded-full text-sm bg-purple-500/20 text-purple-300 border border-purple-500/30">
                  <%= tag %>
                </span>
              <% end %>
            </div>
          </div>
        <% end %>

        <!-- Comments Section (Only show when not editing) -->
        <%= if !@editing_post do %>
          <section class="mt-16">
            <div class="bg-slate-800/30 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-8">
              <h2 class="text-3xl font-bold text-white mb-8 flex items-center gap-3">
                <i class="fas fa-comments text-purple-400"></i>
                <%= gettext("Comments")%>
                <span class="text-lg font-normal text-slate-400">(<%= length(@post.comments) %>)</span>
              </h2>

              <!-- Add Comment Form -->
              <%= if @current_user do %>
                <div class="mb-10">
                  <.simple_form for={%{}} phx-submit="add_comment">
                    <div class="mb-4">
                      <label class="block text-slate-300 font-medium mb-2"> <%= gettext("Add your thoughts")%> </label>
                      <textarea
                        name="comment[body]"
                        rows="4"
                        required
                        class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                        placeholder={gettext("Share your thoughts on this article...")}
                      ></textarea>
                    </div>
                    <:actions>
                      <button
                        type="submit"
                        class="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white font-medium rounded-xl hover:shadow-lg hover:shadow-purple-500/50 transition-all duration-300"
                      >
                        <i class="fas fa-paper-plane mr-2"></i>
                        <%= gettext("Post Comment")%>
                      </button>
                    </:actions>
                  </.simple_form>
                </div>
              <% else %>
                <div class="mb-10 p-6 bg-slate-900/50 border border-slate-600 rounded-xl text-center">
                  <p class="text-slate-300 mb-3"> <%= gettext("Sign in to leave a comment")%> </p>
                  <.link
                    navigate={~p"/users/log_in"}
                    class="inline-block px-6 py-2 bg-purple-500 text-white rounded-lg hover:bg-purple-600 transition-colors"
                  >
                    <%= gettext("Sign In")%>
                  </.link>
                </div>
              <% end %>

              <!-- Comments List -->
              <div class="space-y-6">
                <%= if Enum.empty?(@post.comments) do %>
                  <div class="text-center py-12">
                    <i class="fas fa-comment-slash text-6xl text-slate-600 mb-4"></i>
                    <p class="text-slate-400 text-lg"> <%= gettext("No comments yet. Be the first to share your thoughts!")%></p>
                  </div>
                <% else %>
                  <%= for comment <- @post.comments do %>
                    <div class="bg-slate-900/50 border-l-4 border-purple-500 rounded-r-xl p-6 hover:bg-slate-900/70 transition-colors">
                      <div class="flex items-start gap-4">
                        <img
                          src={comment.user.profile_pic_url || "/images/default-avatar.png"}
                          class="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 p-0.5"
                          alt="User avatar"
                        >
                        <div class="flex-1">
                          <div class="flex items-center gap-3 mb-2">
                            <span class="font-semibold text-white"><%= comment.user.username %></span>
                            <span class="text-sm text-slate-500">
                              <%= if comment.inserted_at do %>
                                <%= Calendar.strftime(comment.inserted_at, "%b %d, %Y at %I:%M %p") %>
                              <% else %>
                                Unknown date
                              <% end %>
                            </span>
                          </div>
                          <p class="text-slate-300 leading-relaxed"><%= comment.body %></p>
                        </div>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </section>
        <% end %>
      </article>
    </div>
    """
  end

  # Helper function to format content (convert newlines to paragraphs)
  defp format_content(body) do
    body
    |> String.split("\n\n")
    |> Enum.map(fn paragraph ->
      "<p class='mb-4'>#{String.replace(paragraph, "\n", "<br>")}</p>"
    end)
    |> Enum.join("")
  end
end