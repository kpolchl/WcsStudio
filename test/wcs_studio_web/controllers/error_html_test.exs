defmodule WcsStudioWeb.ErrorHTMLTest do
  use WcsStudioWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html with the baseline card styling" do
    html = render_to_string(WcsStudioWeb.ErrorHTML, "404", "html", [])

    assert html =~ "Page not found"
    assert html =~ "The page you are looking for does not exist or has moved."
    assert html =~ "rounded-2xl border border-slate-700/50 bg-slate-800/50"
    assert html =~ "Back home"
  end

  test "renders 500.html with the baseline card styling" do
    html = render_to_string(WcsStudioWeb.ErrorHTML, "500", "html", [])

    assert html =~ "Something went wrong"
    assert html =~ "An unexpected error occurred. Please try again later."
    assert html =~ "rounded-2xl border border-slate-700/50 bg-slate-800/50"
    assert html =~ "Back home"
  end
end
