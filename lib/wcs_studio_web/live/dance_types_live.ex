defmodule WcsStudioWeb.DanceTypesLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.Pattern
  alias WcsStudio.DanceType

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        name: "",
        description: ""
      )
    {:ok, socket}
  end

  def handle_event("insert",%{"name" => name, "description" => description}, socket) do
    DanceType.add(name, description)
    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        name: "",
        description: "",
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>Add new Dance Type</h2>
    <form phx-submit="insert">
      Name: <input type="text" name="name" value={@name} /><br /> description:
      <input type="text" name="description" value={@description} /><br />
      <input type="submit" />
    </form>

    <table>
      <tr>
        <th>Name</th>
        <th>Description</th>
      </tr>
      <%= for dance_type <- @dance_types do %>
        <tr>
          <td><%= dance_type.name %></td>
          <td><%= dance_type.description %></td>
        </tr>
      <% end %>
    </table>

    """
  end

end
