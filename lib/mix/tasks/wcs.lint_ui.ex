defmodule Mix.Tasks.Wcs.LintUi do
  @moduledoc """
  Fails when templates hand-write markup that should use a shared UI component.

  The `/patterns` page is the visual baseline, so `core_components.ex` (where the
  components are defined) and `patterns_live.ex` (the reference markup) are
  excluded. Everything else must use `<.btn>`, `<.card>`, `<.badge>` and
  `<.icon_badge>` instead of duplicating gradient/card recipes.

  Run with `mix wcs.lint_ui`.
  """

  @shortdoc "Checks that templates use the shared UI components"

  use Mix.Task

  @web_dir Path.join(["lib", "wcs_studio_web"])
  @excluded ~w(components/core_components.ex live/patterns_live.ex)

  @impl true
  def run(_args) do
    files =
      Path.wildcard(Path.join(@web_dir, "**/*.ex")) ++
        Path.wildcard(Path.join(@web_dir, "**/*.heex"))

    violations =
      files
      |> Enum.reject(&excluded?/1)
      |> Enum.flat_map(&check_file/1)

    if violations == [] do
      Mix.shell().info("UI lint passed — shared components are used consistently.")
    else
      Enum.each(violations, fn {path, line, rule} ->
        Mix.shell().error("#{path}:#{line}: #{rule}")
      end)

      raise Mix.Error,
        message:
          "#{length(violations)} UI lint violation(s). " <>
            "Use the components documented in docs/design-system.md."
    end
  end

  defp excluded?(path) do
    Path.relative_to(path, @web_dir) in @excluded
  end

  defp check_file(path) do
    content = File.read!(path)

    (hand_written_button(content) ++
       hand_written_card(content) ++
       unverified_route(content))
    |> Enum.map(fn {offset, rule} -> {path, line_at(content, offset), rule} end)
  end

  defp hand_written_button(content) do
    ~r/<button\b[^>]*>/s
    |> Regex.scan(content)
    |> Enum.map(&List.first/1)
    |> Enum.filter(&Regex.match?(~r/bg-gradient-to-r\s+from-(pink|purple)/, &1))
    |> Enum.map(fn tag ->
      {byte_offset(content, tag), "hand-written gradient button; use <.btn>"}
    end)
  end

  defp hand_written_card(content) do
    ~r/class="([^"]*)"/s
    |> Regex.scan(content, capture: :all_but_first)
    |> Enum.map(&List.first/1)
    |> Enum.filter(fn class ->
      String.contains?(class, "rounded-2xl") and String.contains?(class, "bg-slate-800/50")
    end)
    |> Enum.map(fn class ->
      {byte_offset(content, class), "hand-written card shell; use <.card>"}
    end)
  end

  defp unverified_route(content) do
    ~r/href="\//
    |> Regex.scan(content)
    |> Enum.map(&List.first/1)
    |> Enum.map(fn match ->
      {byte_offset(content, match), "raw href; use ~p\"\" verified route"}
    end)
  end

  # Regex matches are binaries, so locate the first occurrence to get a line.
  defp byte_offset(content, needle), do: :binary.match(content, needle) |> elem(0)

  defp line_at(content, offset) do
    content
    |> binary_part(0, offset)
    |> String.split("\n")
    |> length()
  end
end
