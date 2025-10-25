defmodule WcsStudioWeb.PieChartComponent do
  use WcsStudioWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign_new(:id, fn -> "pie-chart-#{System.unique_integer([:positive])}" end)
      |> assign_new(:labels, fn -> [] end)
      |> assign_new(:values, fn -> [] end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="pie-chart-container">
      <canvas
        id={@id}
        phx-hook="PieChart"
        data-labels={Enum.join(@labels, ",")}
        data-values={Enum.join(@values, ",")}
      ></canvas>
    </div>
    """
  end
end

