defmodule WcsStudioWeb.Components.LocaleSwitcherTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias WcsStudioWeb.Components.LocaleSwitcher

  describe "locale_switcher/1" do
    test "renders the current locale and both language options" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <LocaleSwitcher.locale_switcher current_locale="pl" current_path="/patterns" />
        """)

      assert html =~ ~s(id="locale-switcher-container")
      assert html =~ ~s(id="locale-dropdown")
      assert html =~ ">pl<"
      assert html =~ "English"
      assert html =~ "Polski"
      assert html =~ "/locale/en"
      assert html =~ "/locale/pl"
      assert html =~ "redirect_to=%2Fpatterns"
    end

    test "defaults to Polish and the root path" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <LocaleSwitcher.locale_switcher />
        """)

      assert html =~ ">pl<"
      assert html =~ "redirect_to=%2F"
    end

    test "only marks the current locale with a check icon" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <LocaleSwitcher.locale_switcher current_locale="en" />
        """)

      assert html =~ ">en<"
      assert html =~ "fa-check"
    end

    test "accepts a custom class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <LocaleSwitcher.locale_switcher current_locale="en" class="my-class" />
        """)

      assert html =~ "my-class"
    end
  end

  describe "mobile_locale_switcher/1" do
    test "renders both locale links in a grid" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <LocaleSwitcher.mobile_locale_switcher current_locale="en" current_path="/blog" />
        """)

      assert html =~ "grid-cols-2"
      assert html =~ "English"
      assert html =~ "Polski"
      assert html =~ "/locale/en"
      assert html =~ "/locale/pl"
      assert html =~ "redirect_to=%2Fblog"
    end
  end
end
