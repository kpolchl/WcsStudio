defmodule WcsStudioWeb.PieChartComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias WcsStudioWeb.PieChartComponent

  describe "render/1" do
    test "renders a canvas with the given id, labels and values" do
      assigns = %{id: "chart-1", labels: ["A", "B"], values: [1, 2]}

      html = render_component(&PieChartComponent.render/1, assigns)

      assert html =~ ~s(id="chart-1")
      assert html =~ ~s(phx-hook="PieChart")
      assert html =~ ~s(data-labels="A,B")
      assert html =~ ~s(data-values="1,2")
    end

    test "renders empty data attributes when there are no labels or values" do
      assigns = %{id: "chart-2", labels: [], values: []}

      html = render_component(&PieChartComponent.render/1, assigns)

      assert html =~ ~s(data-labels="")
      assert html =~ ~s(data-values="")
    end
  end

  describe "mount/1" do
    test "returns the socket unchanged" do
      socket = %Phoenix.LiveView.Socket{}
      assert {:ok, ^socket} = PieChartComponent.mount(socket)
    end
  end

  describe "update/2" do
    test "assigns provided labels and values and generates an id" do
      socket = %Phoenix.LiveView.Socket{}

      assert {:ok, updated} = PieChartComponent.update(%{labels: ["A"], values: [1]}, socket)
      assert updated.assigns.labels == ["A"]
      assert updated.assigns.values == [1]
      assert String.starts_with?(updated.assigns.id, "pie-chart-")
    end

    test "defaults labels and values to empty lists" do
      socket = %Phoenix.LiveView.Socket{}

      assert {:ok, updated} = PieChartComponent.update(%{}, socket)
      assert updated.assigns.labels == []
      assert updated.assigns.values == []
    end

    test "keeps an explicitly provided id" do
      socket = %Phoenix.LiveView.Socket{}

      assert {:ok, updated} = PieChartComponent.update(%{id: "given"}, socket)
      assert updated.assigns.id == "given"
    end
  end
end
