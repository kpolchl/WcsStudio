defmodule WcsStudioWeb.UserProfile do
  use WcsStudioWeb, :live_view
  alias WcsStudio.UserPattern
  alias WcsStudio.UserLesson
  alias WcsStudio.Pattern
  alias WcsStudio.Lesson

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id

    socket = assign(socket,
      all_patterns: Pattern.get_all(),
      all_lessons: Lesson.get_all(),
      user_patterns: UserPattern.get_user_patterns(user_id),
      user_lessons: UserLesson.get_user_lessons(user_id),
      lesson_chart_data: UserLesson.get_chart_data(user_id), # [all_lessons , attended]
      lesson_chart_labels: [gettext("All"), gettext("Attended")],
      user_pattern_chart_data: UserPattern.get_chart_data(user_id), # [all_patterns, in_progress, learned]
      user_pattern_labels: [gettext("Not Learned"), gettext("In Progress"), gettext("Learned")],
      modal_state: nil  # nil | :qr_code
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("open_qr_modal", _, socket) do
    {:noreply, assign(socket, modal_state: :qr_code)}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_state: nil)}
  end

  defp status_class("not_started"), do: "text-gray-400"
  defp status_class("in_progress"), do: "text-blue-400"
  defp status_class("learned"), do: "text-green-400"

  defp border_class("not_started"), do: "hover:border-gray-500/30 hover:shadow-lg hover:shadow-gray-500/10"
  defp border_class("in_progress"), do: "hover:border-blue-500/30 hover:shadow-lg hover:shadow-blue-500/10"
  defp border_class("learned"), do: "hover:border-green-500/30 hover:shadow-lg hover:shadow-green-500/10"

  defp status_bg("not_started"), do: "bg-gray-500/20 text-gray-300 border-gray-500/30"
  defp status_bg("in_progress"), do: "bg-blue-500/20 text-blue-300 border-blue-500/30"
  defp status_bg("learned"), do: "bg-green-500/20 text-green-300 border-green-500/30"

  defp status_icon("not_started"), do: "fa-circle"
  defp status_icon("in_progress"), do: "fa-spinner"
  defp status_icon("learned"), do: "fa-check-circle"

  defp status_text("not_started"), do: gettext("Not Started")
  defp status_text("in_progress"), do: gettext("In Progress")
  defp status_text("learned"), do: gettext("Learned")

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-4">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Hero Section with Profile -->
        <div class="mb-8">
          <div class="bg-gradient-to-r from-blue-600/20 via-cyan-600/20 to-purple-600/20 backdrop-blur-xl border border-white/10 rounded-3xl p-8 shadow-2xl relative overflow-hidden">
            <!-- Decorative elements -->
            <div class="absolute top-0 right-0 w-64 h-64 bg-blue-500/10 rounded-full blur-3xl"></div>
            <div class="absolute bottom-0 left-0 w-64 h-64 bg-purple-500/10 rounded-full blur-3xl"></div>

            <div class="relative flex flex-col lg:flex-row items-center lg:items-start gap-8">
              <!-- Profile Image -->
              <div class="flex-shrink-0">
                <div class="relative group">
                  <div class="absolute -inset-1 bg-gradient-to-r from-blue-500 to-purple-500 rounded-3xl blur opacity-25 group-hover:opacity-40 transition duration-300"></div>
                  <img
                    src={@current_user.profile_pic_url}
                    alt=" "
                    class="relative w-32 h-32 rounded-3xl shadow-2xl object-cover ring-4 ring-white/10"
                  />
                </div>
              </div>

              <!-- Profile Info -->
              <div class="flex-1 text-center lg:text-left">
                <h1 class="text-4xl font-bold text-white mb-2">
                  <%= @current_user.username %>
                </h1>

                <div class="flex flex-wrap items-center justify-center lg:justify-start gap-3 mb-4">
                  <span class="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-medium bg-blue-500/20 text-blue-300 border border-blue-500/30 backdrop-blur-sm">
                    <i class="fas fa-seedling text-xs mr-2"></i> <%= @current_user.role%>
                  </span>
                  <span class="text-slate-300 text-sm flex items-center gap-2">
                    <i class="fas fa-calendar"></i>
                    <span><%= gettext("Joined") %> <%= Calendar.strftime(@current_user.inserted_at, "%B %Y") %></span>
                  </span>
                </div>

                <p class="text-slate-300 text-lg mb-6">
                  <%= @current_user.email %>
                </p>

                <!-- Stats Grid -->
                <div class="grid grid-cols-3 gap-4 max-w-2xl">
                  <div class="bg-slate-800/60 backdrop-blur-sm rounded-2xl p-4 border border-white/5 hover:border-blue-500/30 transition-all duration-300">
                    <div class="flex items-center justify-center mb-2">
                      <div class="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
                        <i class="fas fa-graduation-cap text-blue-400"></i>
                      </div>
                    </div>
                    <p class="text-2xl font-bold text-white mb-1"><%= Enum.at(@lesson_chart_data, 1) %></p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide"><%= gettext("Attended Lessons")%></p>
                  </div>

                  <div class="bg-slate-800/60 backdrop-blur-sm rounded-2xl p-4 border border-white/5 hover:border-green-500/30 transition-all duration-300">
                    <div class="flex items-center justify-center mb-2">
                      <div class="w-10 h-10 rounded-xl bg-green-500/20 flex items-center justify-center">
                        <i class="fas fa-check-double text-green-400"></i>
                      </div>
                    </div>
                    <p class="text-2xl font-bold text-white mb-1"><%= Enum.at(@user_pattern_chart_data, 2) %></p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide"><%= gettext("Patterns Mastered")%></p>
                  </div>

                  <div class="bg-slate-800/60 backdrop-blur-sm rounded-2xl p-4 border border-white/5 hover:border-purple-500/30 transition-all duration-300">
                    <div class="flex items-center justify-center mb-2">
                      <div class="w-10 h-10 rounded-xl bg-purple-500/20 flex items-center justify-center">
                        <i class="fas fa-clock text-purple-400"></i>
                      </div>
                    </div>
                    <p class="text-2xl font-bold text-white mb-1"><%= Float.round(Enum.at(@lesson_chart_data, 1)*1.166666667, 1) %>h</p>
                    <p class="text-xs text-slate-400 uppercase tracking-wide"><%= gettext("Practice Time")%></p>
                  </div>
                </div>
              </div>

              <!-- QR Code Section -->
              <div class="flex-shrink-0">
                <div class="text-center">
                  <div
                    class="cursor-pointer transform hover:scale-105 transition-transform duration-300"
                    phx-click="open_qr_modal"
                  >
                    <div class="rounded-2xl p-4 mb-3 ">
                      <img
                        src={@current_user.qr_code_url}
                        alt={gettext("QR Code")}
                        class="w-32 h-32 mx-auto rounded-lg"
                      />
                    </div>
                    <p class="text-slate-300 text-sm font-medium flex items-center justify-center gap-2">
                      <i class="fas fa-qrcode text-blue-400"></i>
                      <%= gettext("My QR Code")%>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Modals -->
        <%= case @modal_state do %>
          <% :qr_code -> %>
            <.modal id="qr-modal" show={true} on_cancel={JS.push("close_modal")}>
              <div class="text-center">
                <div class="bg-white p-6 rounded-2xl inline-block">
                  <img
                    src={@current_user.qr_code_url}
                    alt={gettext("QR Code")}
                    class="w-64 h-64 mx-auto"
                  />
                </div>
                <p class="text-slate-300 mt-4"><%= gettext("Scan to connect with other dancers")%></p>
              </div>
            </.modal>

          <% nil -> %>
            <!-- No modal open -->
        <% end %>

        <div class="gap-6 mb-8">
          <div class="lg:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-slate-800/40 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-xl hover:border-white/20 transition-all duration-300">
                <div class="flex items-center justify-between mb-6">
                  <h3 class="text-lg font-semibold text-white flex items-center gap-2">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-pink-500 to-purple-500 flex items-center justify-center">
                      <i class="fas fa-shapes text-sm"></i>
                    </div>
                    <span><%= gettext("Pattern Progress")%></span>
                  </h3>
                </div>
              <.live_component
                  module={WcsStudioWeb.PieChartComponent}
                  id="patterns-chart"
                  labels={@user_pattern_labels}
                  values={@user_pattern_chart_data}
                />
            </div>

            <div class="bg-slate-800/40 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-xl hover:border-white/20">
                <div class="flex items-center justify-between mb-6">
                  <h3 class="text-lg font-semibold text-white flex items-center gap-2">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center">
                      <i class="fas fa-chart-pie text-sm"></i>
                    </div>
                    <span><%= gettext("Lesson Attendance")%></span>
                  </h3>
                </div>
              <.live_component
                  module={WcsStudioWeb.PieChartComponent}
                  id="lesson-chart"
                  labels={@lesson_chart_labels}
                  values={@lesson_chart_data}
                />
            </div>
          </div>
        </div>

        <!-- Patterns Section -->
        <div class="bg-slate-800/40 backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-xl">
          <div class="flex items-center justify-between mb-8">
            <h2 class="text-2xl font-bold text-white flex items-center gap-3">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-pink-500 to-purple-500 flex items-center justify-center">
                <i class="fas fa-shapes"></i>
              </div>
              <span><%= gettext("My Patterns")%></span>
            </h2>

            <%= if Enum.any?(@user_patterns) do %>
              <a href={~p"/patterns"} class="text-sm text-blue-400 hover:text-blue-300 flex items-center gap-2 transition-colors">
                <span><%= gettext("View All")%></span>
                <i class="fas fa-arrow-right text-xs"></i>
              </a>
            <% end %>
          </div>

          <%= if Enum.any?(@user_patterns) do %>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <%= for user_pattern <- @user_patterns do %>
                <div class={"group bg-slate-800/60 backdrop-blur-sm border border-white/5 rounded-xl p-5 transition-all duration-300 hover:scale-[1.02] #{border_class(user_pattern.status)}"}>
                  <div class="flex items-start justify-between mb-3">
                    <h3 class="text-base font-semibold text-white group-hover:text-blue-300 transition-colors"><%= user_pattern.pattern.name %></h3>
                    <span class={"inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-medium border backdrop-blur-sm #{status_bg(user_pattern.status)}"}>
                      <i class={"fas #{status_icon(user_pattern.status)} mr-1.5 text-xs"}></i>
                      <%= status_text(user_pattern.status) %>
                    </span>
                  </div>

                  <p class="text-slate-400 text-sm mb-4 line-clamp-2 leading-relaxed">
                    <%= if @locale == "en" do %>
                      <%= user_pattern.pattern.general_description_en %>
                    <% else %>
                      <%= user_pattern.pattern.general_description_pl %>
                    <% end %>
                  </p>

                  <div class="flex items-center justify-between pt-3 border-t border-white/5">
                    <div class={"flex items-center text-xs font-medium #{status_class(user_pattern.status)}"}>
                      <i class={"fas #{status_icon(user_pattern.status)} mr-1.5"}></i>
                      <%= status_text(user_pattern.status) %>
                    </div>
                    <a href={~p"/patterns"} class="text-blue-400 hover:text-blue-300 text-xs font-medium flex items-center gap-1 transition-colors">
                      <span><%= gettext("Details")%></span>
                      <i class="fas fa-arrow-right text-[10px]"></i>
                    </a>
                  </div>
                </div>
              <% end %>
            </div>
          <% else %>
            <div class="text-center py-20">
              <div class="w-24 h-24 mx-auto mb-6 rounded-3xl bg-slate-800/50 flex items-center justify-center">
                <i class="fas fa-shapes text-4xl text-slate-600"></i>
              </div>
              <h3 class="text-xl font-semibold text-slate-300 mb-2"><%= gettext("No patterns yet")%></h3>
              <p class="text-slate-500 mb-8 max-w-md mx-auto"><%= gettext("Start your dance journey by exploring and tracking patterns")%></p>
              <a href={~p"/patterns"} class="inline-flex items-center gap-2 bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600 text-white font-semibold py-3 px-8 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300">
                <i class="fas fa-plus"></i>
                <span><%= gettext("Browse Patterns")%></span>
              </a>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end