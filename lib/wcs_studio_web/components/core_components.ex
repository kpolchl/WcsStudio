defmodule WcsStudioWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import WcsStudioWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-slate-900/80 backdrop-blur-sm fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center p-4">
          <div class="w-full max-w-md">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden transition"
            >
              <!-- Modal Content -->
              <div class="bg-slate-800/90 backdrop-blur-sm rounded-xl border border-slate-700/50 shadow-2xl p-6">
                <%= render_slot(@inner_block) %>
              </div>

              <!-- Close Button -->
              <div class="absolute -top-3 -right-3">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="w-8 h-8 rounded-full bg-slate-700 border border-slate-600/50 flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 transition-all duration-300 hover:shadow-lg"
                  aria-label={gettext("close")}
                >
                  <i class="fas fa-times text-sm"></i>
                </button>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a confirmation modal for destructive actions.

  ## Examples

      <.confirm_modal
        id="delete-pattern-123"
        title="Delete Pattern?"
        message="Are you sure you want to delete this pattern? This action cannot be undone."
        confirm_event="confirm_delete_pattern"
        confirm_value={@pattern.id}
      />
  """
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :message, :string, required: true
  attr :confirm_event, :string, required: true
  attr :confirm_value, :any, default: nil
  attr :cancel_text, :string, default: nil
  attr :confirm_text, :string, default: nil

  def confirm_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:cancel_text, fn -> gettext("Cancel") end)
      |> assign_new(:confirm_text, fn -> gettext("Delete") end)

    ~H"""
    <.modal id={@id}>
      <div class="text-center">
        <!-- Warning Icon -->
        <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-red-500 to-pink-500 mb-4">
          <i class="fas fa-exclamation-triangle text-white text-2xl"></i>
        </div>

        <!-- Title -->
        <h3 class="text-2xl font-bold text-slate-900 mb-3">
          <%= @title %>
        </h3>

        <!-- Message -->
        <p class="text-slate-600 mb-8 leading-relaxed">
          <%= @message %>
        </p>

        <!-- Actions -->
        <div class="flex gap-3 justify-center">
          <button
            phx-click={JS.exec("data-cancel", to: "##{@id}")}
            type="button"
            class="bg-slate-200 hover:bg-slate-300 text-slate-700 font-medium py-2.5 px-6 rounded-lg transition-all duration-200"
          >
            <%= @cancel_text %>
          </button>

          <button
            phx-click={@confirm_event}
            phx-value-id={@confirm_value}
            type="button"
            class="bg-gradient-to-r from-red-500 to-pink-600 hover:from-red-600 hover:to-pink-700 text-white font-medium py-2.5 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-red-500/25"
          >
            <i class="fas fa-trash mr-2"></i>
            <%= @confirm_text %>
          </button>
        </div>
      </div>
    </.modal>
    """
  end

  @doc """
  Renders a form modal with customizable fields.

  ## Examples

      <.form_modal
        id="new-pattern-modal"
        show={@show_modal}
        title="New Pattern"
        subtitle="Fill out the form to add a new pattern"
        form={@form}
        on_cancel={JS.push("close_modal")}
        on_submit="save"
      >
        <.input type="text" field={@form[:name]} label="Title" />
        <.input type="textarea" field={@form[:description]} label="Description" />
      </.form_modal>

      # With custom submit button styling
      <.form_modal
        id="update-modal"
        show={@show_update}
        title="Update Item"
        form={@form}
        on_submit="update"
        submit_label="Update"
        submit_class="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700"
      >
        <.input type="text" field={@form[:name]} label="Name" />
      </.form_modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :form, :any, required: true
  attr :on_cancel, JS, default: %JS{}
  attr :on_submit, :string, required: true
  attr :on_change, :string, default: "validate"
  attr :submit_label, :string, default: nil
  attr :cancel_label, :string, default: nil
  attr :submit_class, :string, default: nil

  slot :inner_block, required: true

  def form_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:submit_label, fn -> gettext("Save") end)
      |> assign_new(:cancel_label, fn -> gettext("Cancel") end)

    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-slate-900/80 backdrop-blur-sm fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center p-4">
          <div class="w-full max-w-2xl">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden rounded-2xl bg-slate-800 border border-slate-700/50 shadow-2xl transition-all transform"
            >
              <!-- Header -->
              <div class="relative p-6 pb-4 border-b border-slate-700/50">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="absolute top-4 right-4 w-8 h-8 rounded-lg bg-slate-700/50 hover:bg-slate-600/50 flex items-center justify-center transition-all duration-200 group"
                  aria-label={gettext("close")}
                >
                  <i class="fas fa-times text-slate-400 group-hover:text-white text-sm"></i>
                </button>

                <div class="pr-8">
                  <h2 id={"#{@id}-title"} class="text-2xl font-bold text-white mb-1">
                    <%= @title %>
                  </h2>
                  <p :if={@subtitle} id={"#{@id}-description"} class="text-slate-400 text-sm">
                    <%= @subtitle %>
                  </p>
                </div>
              </div>

              <!-- Form Content -->
              <div id={"#{@id}-content"} class="p-6">
                <.form for={@form} phx-submit={@on_submit} phx-change={@on_change}>
                  <div class="space-y-4">
                    <%= render_slot(@inner_block) %>
                  </div>

                  <!-- Actions -->
                  <div class="mt-8 flex justify-end gap-3 pt-6 border-t border-slate-700/50">
                    <button
                      type="button"
                      phx-click={JS.exec("data-cancel", to: "##{@id}")}
                      class="px-5 py-2.5 text-sm font-medium text-slate-300 bg-slate-700/50 border border-slate-600/50 rounded-lg hover:bg-slate-600/50 hover:text-white transition-all duration-200"
                    >
                      <%= @cancel_label %>
                    </button>
                    <button
                      type="submit"
                      class={[
                        "px-5 py-2.5 text-sm font-medium text-white rounded-lg transition-all duration-200 shadow-lg hover:shadow-xl hover:-translate-y-0.5 flex items-center gap-2",
                        @submit_class || "bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600"
                      ]}
                    >
                      <i class="fas fa-save text-xs"></i>
                      <%= @submit_label %>
                    </button>
                  </div>
                </.form>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end


  @doc """
  Render pattern block.

  # Examples
  """

  defp status_class("not_started"), do: "from-gray-400 to-gray-500 hover:from-gray-500 hover:to-gray-600"
  defp status_class("in_progress"), do: "from-yellow-400 to-yellow-500 hover:from-yellow-500 hover:to-yellow-600"
  defp status_class("learned"), do: "from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700"

  defp status_icon("not_started"), do: "fa-spinner"
  defp status_icon("in_progress"), do: "fa-spinner"
  defp status_icon("learned"), do: "fa-check-circle"

  defp status_text("not_started"), do: gettext("Start")
  defp status_text("in_progress"), do: gettext("In Progress")
  defp status_text("learned"), do: gettext("Learned")

  attr :pattern, :map, required: true, doc: "Pattern data"
  attr :current_user, :map, required: false, doc: "current user data"
  attr :expanded_pattern_id, :map, required: true, doc: "flag to expand or hide content"
  attr :status, :map, required: false, doc: "for update status on the bottom"
  attr :locale, :map, required: false, doc: "for simple translation"



  def pattern(assigns) do
    ~H"""
    <div id={"-card-#{@pattern.id}"} phx-click="toggle_pattern" phx-value-id={@pattern.id} class="bg-slate-800/50 backdrop-blur-sm rounded-xl border border-slate-700/50 shadow-xl transition-all duration-300 cursor-pointer hover:shadow-2xl hover:border-pink-500/30 hover:-translate-y-1">
      <div class="p-6 flex items-start justify-between">
        <div class="flex-1 min-w-0">
          <div class="flex flex-wrap gap-2 mb-3">
            <span class="px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-purple-300 border border-purple-500/30">
                  { WcsStudio.DanceType.get_name(@pattern.dance_type, @locale) }
            </span>
          </div>
          <h2 class="text-2xl font-bold text-white mb-2 bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
              {@pattern.name}
          </h2>
        </div>
      </div>

      <!-- Collapsed body preview -->
      <div class={if @expanded_pattern_id == @pattern.id, do: "hidden", else: "px-6 pb-4 pt-0"} id={"preview-body-#{@pattern.id}"}>
        <p class="text-slate-400 line-clamp-2 text-sm leading-relaxed">
          <%= WcsStudio.Pattern.get_general_description(@pattern, @locale) %>
        </p>
        <div class="flex items-center mt-3 text-slate-500 text-xs">
          <i class="fas fa-info-circle mr-1"></i>
          <span><%= gettext("Click to expand pattern details") %></span>
        </div>

      </div>

      <!-- Expanded content -->
      <div id={"expanded-body-#{@pattern.id}"} class={unless @expanded_pattern_id == @pattern.id, do: "hidden", else: "px-6 pb-6 pt-0 border-t border-slate-700/50 mt-4"}>

        <!-- Description -->
        <div class="mb-6 py-4">
          <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-green-500 to-emerald-600 flex items-center justify-center mr-3 shadow-lg">
                  <i class="fas fa-note-sticky text-xs"></i>
              </div>
              <h2 class="text-xl font-bold text-white"><%= gettext("General Description") %></h2>
            </div>
            <div class="flex items-center p-3 rounded-lg bg-slate-600/30 border border-slate-500/30">
            <p class="text-slate-300 text-sm leading-relaxed">
              <%= WcsStudio.Pattern.get_general_description(@pattern, @locale) %>
            </p>
            </div>
          </div>
        </div>

        <div class="mb-6">
          <div class="grid grid-cols-1 gap-6 md:grid-cols-2 mt-6">
            <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg">
              <div class="flex items-center mb-4">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center mr-3 shadow-lg">
                  <i class="fas fa-chess-king text-white text-sm"></i>
                </div>
                <h2 class="text-xl font-bold text-white"><%= gettext("For Leaders") %></h2>
              </div>
              <div class="flex items-center p-3 rounded-lg bg-slate-600/30 border border-slate-500/30">
              <p class="text-slate-300 text-sm leading-relaxed">
                <%= WcsStudio.Pattern.get_leader_description(@pattern, @locale) %>
              </p>
              </div>

            </div>
            <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg">
              <div class="flex items-center mb-4">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center mr-3 shadow-lg">
                  <i class="fas fa-chess-queen text-white text-sm"></i>
                </div>
                <h2 class="text-xl font-bold text-white"><%= gettext("For Followers") %></h2>
              </div>
              <div class="flex items-center p-3 rounded-lg bg-slate-600/30 border border-slate-500/30">
              <p class="text-slate-300 text-sm leading-relaxed">
                <%= WcsStudio.Pattern.get_follower_description(@pattern, @locale) %>
              </p>
              </div>
            </div>
          </div>
        </div>


        <!-- Video -->
        <div class="mt-6">
            <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg  max-w-2xl mx-auto">
              <div class="flex items-center mb-4">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center mr-3 shadow-lg">
                  <i class="fas fa-play text-white text-sm"></i>
                </div>
                <h2 class="text-xl font-bold text-white"><%= gettext("Showcase Video") %></h2>
              </div>
              <div class="bg-slate-800/50 rounded-xl p-4 border border-slate-700/50">
                <div class="w-full rounded-lg shadow-lg overflow-hidden">
                  <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                    <iframe
                      class="absolute top-0 left-0 w-full h-full"
                      src={@pattern.video_url}
                      title={gettext("YouTube video player")}
                      frameborder="0"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                      allowfullscreen>
                    </iframe>
                  </div>
                </div>
              </div>
            </div>
          </div>


        <!-- Actions -->
        <div class="flex justify-end gap-3 mt-6">
          <%= if @current_user do %>
            <% status = @status || "not_started" %>

              <button
              phx-click="update_status"
              phx-value-pattern_id={@pattern.id}
              phx-value-user_id={@current_user.id}
              phx-value-status={status}
              class={"bg-gradient-to-r #{status_class(status)} text-white font-medium py-2 px-4 rounded-lg transition-all duration-300 hover:shadow-lg flex items-center"}>
                <i class={"fas #{status_icon(status)} mr-2"}></i>
                <%= status_text(status) %>
              </button>
            <% end %>

          <%= if @current_user && @current_user.role == "admin" do %>
            <button phx-click="open_update_modal" phx-value-id={@pattern.id}
              class="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 text-white font-medium py-2 px-4 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-blue-500/25 hover:-translate-y-0.5 flex items-center">
              <i class="fas fa-edit mr-2"></i>
                <%= gettext("Update") %>
            </button>

            <button
              phx-click={show_modal("confirm-delete-pattern-#{@pattern.id}")}
              class="bg-gradient-to-r from-red-500 to-pink-600 hover:from-red-600 hover:to-pink-700 text-white font-medium py-2 px-4 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-red-500/25 hover:-translate-y-0.5 flex items-center"
              >
              <i class="fas fa-trash mr-2"></i>
              <%= gettext("Delete") %>
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
    renders a lesson block

  ## Examples

  """

  defp attended_class(false), do: "from-gray-400 to-gray-500 hover:from-gray-500 hover:to-gray-600"
  defp attended_class(true), do: "from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700"

  defp attended_icon(false), do: "fa-circle"
  defp attended_icon(true), do: "fa-check-circle"

  defp attended_text(false), do: gettext("Not Attended")
  defp attended_text(true), do: gettext("Attended")

  attr :lesson, :map, required: true, doc: "lesson data"
  attr :current_user, :map, required: true, doc: "current user data"
  attr :expanded_lesson_id, :map, required: true, doc: "current user data"
  attr :attended, :map, required: false, doc: "for update attended on the bottom"
  attr :locale, :map, required: false, doc: "for localization"


  def lesson_box(assigns) do
    ~H"""
    <div id={"lesson-card-#{@lesson.id}"}
      phx-click="toggle_lesson" phx-value-id={@lesson.id}
      class="group bg-slate-800/50 backdrop-blur-sm rounded-2xl border border-slate-700/50 shadow-xl transition-all duration-300 mb-6 cursor-pointer hover:shadow-2xl hover:border-pink-500/30 max-w-4xl mx-auto hover:-translate-y-1">

      <div class="p-6 flex items-start justify-between">
        <div class="flex-1 min-w-0">
            <div class="flex flex-wrap gap-2 mb-3">
              <span class="px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-purple-500/20 to-pink-500/20 text-purple-300 border border-purple-500/30">
                <i class="fas fa-music mr-1"></i>
                { WcsStudio.DanceType.get_name(@lesson.dance_type , @locale)}
              </span>
              <span class="px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-green-500/20 to-emerald-500/20 text-green-300 border border-green-500/30">
                <i class="fas fa-chart-line mr-1"></i>
                {@lesson.level.name}
              </span>
            </div>
            <h2 class="text-2xl font-bold text-white mb-3 bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
              {@lesson.title}
            </h2>
            <div class="flex items-center text-sm text-slate-400 space-x-4">
              <div class="flex items-center">
                <i class="fas fa-calendar-day mr-2 text-blue-400"></i>
                <span>{@lesson.date}</span>
              </div>
              <div class="flex items-center">
                <i class="fas fa-map-marker-alt mr-2 text-red-400"></i>
                <span>{@lesson.place}</span>
              </div>
            </div>
        </div>
        <div class="flex-shrink-0 transition-transform duration-300 ml-4 group">
            <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300">
              <i class={["fas fa-chevron-down text-white transition-transform duration-300",if(@expanded_lesson_id == @lesson.id, do: "rotate-180", else: "group-hover:rotate-180")]}></i>
            </div>
        </div>
      </div>

      <!-- Collapsed body preview -->
      <div class={if @expanded_lesson_id == @lesson.id, do: "hidden", else: "px-6 pb-4 pt-0"} id={"preview-body-#{@lesson.id}"}>
        <div class="flex items-center text-sm text-slate-400">
          <div class="flex -space-x-2 mr-3">
            <%= for instructor <- @lesson.instructors do %>
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 border-2 border-slate-800 flex items-center justify-center text-xs font-bold text-white shadow-lg">
                <%= String.first(instructor.username) %>
              </div>
            <% end %>
          </div>
          <span>
            <i class="fas fa-users mr-1"></i>
            <%= ngettext("1 instructor", "%{count} instructors", length(@lesson.instructors)) %>
          </span>
        </div>
      </div>

      <!-- Expanded content -->
      <div class={unless @expanded_lesson_id == @lesson.id, do: "hidden", else: "px-6 pb-6 pt-0 border-t border-slate-700/50 mt-4"} id={"expanded-body-#{@lesson.id}"}>
        <div class="grid grid-cols-1 gap-6 md:grid-cols-2 mt-6">
          <!-- Patterns Box -->
          <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center mr-3 shadow-lg">
                <i class="fas fa-shapes text-white text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-white"><%= gettext("Patterns") %></h2>
            </div>
            <div class="space-y-3">
              <%= for pattern <- @lesson.patterns do %>
              <div class="bg-slate-600/30 p-3 rounded-lg flex items-center">
                <i class="fas fa-circle text-blue-400 text-xs mr-3 animate-pulse"></i>
                <span class="font-medium text-slate-200"><%= pattern.name %></span>
              </div>
              <% end %>
            </div>
          </div>

          <!-- Instructors Box -->
          <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg ">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center mr-3 shadow-lg">
                <i class="fas fa-users text-white text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-white"><%= gettext("Instructors") %></h2>
            </div>
            <div class="space-y-4">
              <%= for instructor <- @lesson.instructors do %>
              <div class="flex items-center p-3 rounded-lg bg-slate-600/30 ">
                <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center mr-3 shadow-lg">
                  <span class="font-bold text-white text-sm"><%= String.first(instructor.username) %></span>
                </div>
                <div>
                  <h3 class="font-semibold text-white"><%= instructor.username %></h3>
                  <p class="text-sm text-slate-400"><%= gettext("Dance Instructor") %></p>
                </div>
              </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Video Section -->
        <div class="mt-6">
          <div class="p-6 rounded-xl bg-slate-700/30 backdrop-blur-sm border border-slate-600/50 shadow-lg  max-w-2xl mx-auto">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center mr-3 shadow-lg">
                <i class="fas fa-play text-white text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-white"><%= gettext("Video Lesson") %></h2>
            </div>
            <div class="bg-slate-800/50 rounded-xl p-4 border border-slate-700/50">
              <div class="w-full rounded-lg shadow-lg overflow-hidden">
                <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                  <iframe
                    class="absolute top-0 left-0 w-full h-full"
                    src={@lesson.lesson_vid_url}
                    title={gettext("YouTube video player")}
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen>
                  </iframe>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 mt-6 pt-6 border-t border-slate-700/50">
          <%= if @current_user do%>
              <% attended = @attended || false %>
              <button
              phx-click="toggle_attendance"
              phx-value-lesson_id={@lesson.id}
              phx-value-user_id={@current_user.id}
              phx-value-attended={attended}
              class={"bg-gradient-to-r #{attended_class(attended)} text-white font-medium py-2 px-4 rounded-lg transition-all duration-300 hover:shadow-lg flex items-center"}>
                <i class={"fas #{attended_icon(attended)} mr-2"}></i>
                <%= attended_text(attended) %>
              </button>

          <% end %>

          <%= if @current_user && @current_user.role == "admin" do %>
            <button phx-click="open_update_modal" phx-value-id={@lesson.id}
              class="bg-gradient-to-r from-blue-500 to-cyan-600 hover:from-blue-600 hover:to-cyan-700 text-white font-medium py-3 px-6 rounded-xl transition-all duration-300 hover:shadow-lg hover:shadow-blue-500/25 hover:-translate-y-0.5 flex items-center">
              <i class="fas fa-edit mr-2"></i>
                <%= gettext("Update Lesson") %>
            </button>

            <button
              phx-click={show_modal("confirm-delete-lesson-#{@lesson.id}")}
              class="bg-gradient-to-r from-red-500 to-pink-600 hover:from-red-600 hover:to-pink-700 text-white font-medium py-2 px-4 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-red-500/25 hover:-translate-y-0.5 flex items-center"
              >
              <i class="fas fa-trash mr-2"></i>
                <%= gettext("Delete") %>
            </button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end



  @doc """
  Renders post block.

  ## Examples

  """

  attr :post, :map, required: true, doc: "Post data"

  def post_highlight(assigns) do
    ~H"""
    <.link
    href={"/blog/#{@post.id}"}
    class="block group bg-slate-800/50 backdrop-blur-sm rounded-2xl border border-slate-700/50 shadow-xl transition-all duration-500 hover:shadow-2xl hover:border-pink-500/30 hover:-translate-y-1 overflow-hidden"
    >
    <div class="p-8">
    <div class="flex items-center gap-2 mb-4">
      <span class="px-3 py-1 rounded-full text-sm bg-pink-500/20 text-pink-300 border border-pink-500/30">
        <%= @post.subject %>
      </span>
      <span class="px-3 py-1 rounded-full text-sm bg-slate-700/50 text-slate-300 border border-slate-600/50 backdrop-blur-sm">
          <%= WcsStudio.Post.estimate_read_time(@post.body) %>
      </span>
    </div>

    <h2 class="text-2xl font-bold text-white mb-4 group-hover:text-transparent group-hover:bg-gradient-to-r group-hover:from-pink-500 group-hover:to-purple-500 group-hover:bg-clip-text transition-all duration-300">
      <%= @post.title %>
    </h2>

    <p class="text-slate-300 leading-relaxed mb-6 line-clamp-3">
      <%= @post.body %>
    </p>

    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <img
          src={@post.user.profile_pic_url || "/images/default-avatar.png"}
          class="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 p-0.5"
          alt={@post.user.username}
        >
        <div>
          <p class="font-medium text-white"><%= @post.user.username %></p>
          <p class="text-sm text-slate-400">
            <%= if @post.inserted_at do %>
              <%= Calendar.strftime(@post.inserted_at, "%b %d, %Y") %>
            <% else %>
              <%= gettext("Unknown date") %>
            <% end %>
          </p>
        </div>
      </div>
      <div class="flex items-center gap-6 text-slate-400">
        <div class="flex items-center gap-2 group-hover:text-pink-400 transition-colors">
          <i class="fas fa-arrow-right"></i>
          <span><%= gettext("Read more") %></span>
        </div>
      </div>
    </div>
    </div>
    </.link>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error, :warning, :success], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-4 right-4 z-50 rounded-2xl p-4 backdrop-blur-sm border shadow-2xl max-w-sm transform transition-all duration-300 cursor-pointer group hover:-translate-y-1",
        @kind == :info && "bg-slate-800/80 border-cyan-500/30 text-cyan-300 shadow-cyan-500/10 hover:border-cyan-400/50",
        @kind == :error && "bg-slate-800/80 border-rose-500/30 text-rose-300 shadow-rose-500/10 hover:border-rose-400/50",
        @kind == :warning && "bg-slate-800/80 border-amber-500/30 text-amber-300 shadow-amber-500/10 hover:border-amber-400/50",
        @kind == :success && "bg-slate-800/80 border-emerald-500/30 text-emerald-300 shadow-emerald-500/10 hover:border-emerald-400/50"
      ]}
      phx-mounted={JS.dispatch("flash:mounted", to: "##{@id}")}
      {@rest}
    >
      <div class="flex items-start gap-3">
        <!-- Icon Container -->
        <div class={[
          "flex-shrink-0 w-10 h-10 rounded-xl flex items-center justify-center shadow-lg",
          @kind == :info && "bg-gradient-to-br from-cyan-500 to-blue-500",
          @kind == :error && "bg-gradient-to-br from-rose-500 to-pink-500",
          @kind == :warning && "bg-gradient-to-br from-amber-500 to-orange-500",
          @kind == :success && "bg-gradient-to-br from-emerald-500 to-green-500"
        ]}>
          <i class={[
            "text-white text-sm",
            @kind == :info && "fas fa-info-circle",
            @kind == :error && "fas fa-exclamation-triangle",
            @kind == :warning && "fas fa-exclamation-circle",
            @kind == :success && "fas fa-check-circle"
          ]}></i>
        </div>

        <!-- Content -->
        <div class="flex-1 min-w-0">
          <p :if={@title} class="font-semibold text-white text-sm leading-6 mb-1">
            <%= @title %>
          </p>
          <p class="text-sm leading-5 opacity-90"><%= msg %></p>
        </div>

        <!-- Close Button -->
        <button
          type="button"
          phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
          class="flex-shrink-0 w-8 h-8 rounded-xl bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200 group-hover:scale-110"
          aria-label={gettext("close")}
        >
          <i class="fas fa-times text-xs text-white/70 group-hover:text-white"></i>
        </button>
      </div>

      <!-- Progress Bar -->
      <div class={[
        "w-full h-1 rounded-full mt-3 overflow-hidden",
        @kind == :info && "bg-cyan-500/20",
        @kind == :error && "bg-rose-500/20",
        @kind == :warning && "bg-amber-500/20",
        @kind == :success && "bg-emerald-500/20"
      ]}>
        <div class={[
          "h-full rounded-full progress-bar",
          @kind == :info && "bg-gradient-to-r from-cyan-400 to-blue-400",
          @kind == :error && "bg-gradient-to-r from-rose-400 to-pink-400",
          @kind == :warning && "bg-gradient-to-r from-amber-400 to-orange-400",
          @kind == :success && "bg-gradient-to-r from-emerald-400 to-green-400"
        ]} style="width: 0"></div>
      </div>
    </div>
    """
  end


  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        <%= gettext("Attempting to reconnect") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <%= gettext("Hang in there while we get back on track") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
       include: ~w(autocomplete name rel action enctype method novalidate target multipart),
       doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 ">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
       default: "text",
       values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
       doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
       include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-3 text-sm leading-6 text-white">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[
            "rounded border-slate-600 bg-slate-800/50 text-pink-500 focus:ring-2 focus:ring-pink-500 focus:ring-opacity-20 transition-all duration-300",
            "checked:bg-pink-500 checked:border-pink-500 hover:border-pink-400/50",
            "w-4 h-4",
            @errors == [] && "border-slate-600 focus:border-pink-500",
            @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-500"
          ]}
          {@rest}
        />
        <span class="text-slate-300 hover:text-white transition-colors duration-200"><%= @label %></span>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
    <.label for={@id} class="text-white font-medium mb-2 block"><%= @label %></.label>
    <select
    id={@id}
    name={@name}
    class={[
      "block w-full rounded-lg text-white focus:ring-2 focus:ring-opacity-20 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
      "phx-no-feedback:border-slate-600/50 phx-no-feedback:focus:border-pink-500/50",
      "bg-slate-800/50 border border-slate-600/50 px-4 py-3",
      @errors == [] && "border-slate-600/50 focus:border-pink-500/50 focus:ring-pink-500",
      @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-500"
    ]}
    multiple={@multiple}
    {@rest}
    >
    <option :if={@prompt} value=""><%= @prompt %></option>
    <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
    </select>
    <.error :for={msg <- @errors} class="mt-2 text-sm text-rose-400"><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "block w-full rounded-lg text-white placeholder-slate-400 focus:ring-2 focus:ring-opacity-20 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
          "min-h-[6rem] phx-no-feedback:border-slate-600/50 phx-no-feedback:focus:border-pink-500/50",
          "bg-slate-800/50 border border-slate-600/50",
          @errors == [] && "border-slate-600/50 focus:border-pink-500/50 focus:ring-pink-500",
          @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-500"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "block w-full rounded-lg text-white placeholder-slate-400 focus:ring-2 focus:ring-opacity-20 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
          "phx-no-feedback:border-slate-600/50 phx-no-feedback:focus:border-pink-500/50",
          "bg-slate-800/50 border border-slate-600/50 px-4 py-3",
          @errors == [] && "border-slate-600/50 focus:border-pink-500/50 focus:ring-pink-500",
          @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-500"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-white font-medium mb-2">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-3xl font-bold text-white mb-4 bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="text-slate-400">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
       default: &Function.identity/1,
       doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
        "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
        "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
        "opacity-100 translate-y-0 sm:scale-100",
        "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
         to: "##{id}-bg",
         transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
       )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
         to: "##{id}-bg",
         transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
       )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(WcsStudioWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(WcsStudioWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end