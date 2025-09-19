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
        patterns: Pattern.get_by_dance_type_id(first_dance_type.id),
        name: "",
        description: "",
        video_url: nil,
        query: ""
      )

    {:ok, socket}
  end

  def handle_event("insert",%{"name" => name, "description" => description, "video_url" => video_url}, socket) do
    Pattern.add(socket.assigns.dance_type_id, name, description, video_url)
    socket =
      assign(socket,
        patterns: Pattern.get_by_dance_type_id(socket.assigns.dance_type_id),
        dance_type_id: socket.assigns.dance_type_id,
        name: "",
        description: "",
        video_url: ""
      )

    {:noreply, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket =
      assign(socket,
        patterns: Pattern.get_by_id_name_or_description(socket.assigns.dance_type_id, query),
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

  def render(assigns) do
    ~H"""
    <form phx-change="choose">
      <select name="dance_type_id">
        <%= for dance_type <- @dance_types do %>
          <option value={dance_type.id} selected={dance_type.id == @dance_type_id}>
            <%= dance_type.name %>
          </option>
        <% end %>
      </select>
    </form>
    Search
    <form phx-change="search">
      <input type="text" name="query" value={@query} />
    </form>

    <h2>Add new Pattern</h2>
    <form phx-submit="insert">
      Name: <input type="text" name="name" value={@name} /><br /> description:
      <input type="text" name="description" value={@description} /><br /> video_url:
      <input type="text" name="video_url" value={@video_url} /><br />
      <input type="submit" />
    </form>

    <table>
      <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Video_url</th>
      </tr>
      <%= for pattern <- @patterns do %>
        <tr>
          <td><%= pattern.name %></td>
          <td><%= pattern.description %></td>
          <td><%= pattern.video_url %></td>
        </tr>
      <% end %>
    </table>
    """
  end
end
