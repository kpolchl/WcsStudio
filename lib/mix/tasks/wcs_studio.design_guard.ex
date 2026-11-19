defmodule Mix.Tasks.WcsStudio.DesignGuard do
  @moduledoc """
  Checks that web templates obey the token rules in `DESIGN.md`.

  Usage: `mix wcs_studio.design_guard`
  """

  use Mix.Task

  @shortdoc "Checks DESIGN.md token rules across web templates"

  @roots ~w(
    lib/wcs_studio_web/components
    lib/wcs_studio_web/controllers
    lib/wcs_studio_web/live
  )

  @rules [
    {"raw palette color",
     ~r/\b(?:purple|pink|cyan|orange|amber|yellow|emerald|green|red|blue)-\d/},
    {"raw gray color", ~r/\b(?:bg|text|border|from|to)-gray-\d/},
    {"forbidden radius", ~r/\brounded-(?:none|2xl|3xl)\b/},
    {"off-scale spacing",
     ~r/\b(?:py-2\.5|px-5|py-3\.5|px-3\.5|gap-5|gap-7|mt-1\.5|mb-1\.5|py-1\.5)\b/},
    {"raw slate text color", ~r/\btext-slate-/}
  ]

  @impl Mix.Task
  def run(_args) do
    violations =
      @roots
      |> Enum.flat_map(&files/1)
      |> Enum.flat_map(fn path ->
        path
        |> File.read!()
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.flat_map(fn {line, number} ->
          Enum.flat_map(@rules, fn {label, pattern} ->
            if Regex.match?(pattern, line),
              do: [{path, number, label, String.trim(line)}],
              else: []
          end)
        end)
      end)

    if violations == [] do
      Mix.shell().info("DESIGN.md guardrails passed.")
    else
      Enum.each(violations, fn {path, number, label, line} ->
        Mix.shell().error("#{path}:#{number}: #{label}: #{line}")
      end)

      Mix.raise("Design guardrails failed (#{length(violations)} violation(s)).")
    end
  end

  defp files(directory) do
    directory
    |> Path.join("**/*")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
  end
end
