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

  Icons are provided by [Font Awesome](https://fontawesome.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS
  use Gettext, backend: WcsStudioWeb.Gettext

  @default_avatar_url "/images/user_icon.png"

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
  slot :title
  slot :subtitle

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="ModalFocus"
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="bg-surface-base/80 backdrop-blur-sm fixed inset-0 transition-opacity"
        aria-hidden="true"
      />
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
              <div class="bg-surface-raised rounded-lg border border-surface-muted/50 shadow-card p-6">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="absolute top-4 right-4 w-8 h-8 rounded-md bg-surface-muted/50 hover:bg-surface-muted flex items-center justify-center transition-all duration-200 group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70"
                  aria-label={gettext("close")}
                >
                  <i class="fas fa-times text-muted group-hover:text-strong text-sm"></i>
                </button>
                <div :if={@title != [] || @subtitle != []} class="pr-12 mb-4">
                  <h2
                    :if={@title != []}
                    id={"#{@id}-title"}
                    class="text-heading font-bold text-strong"
                  >
                    {render_slot(@title)}
                  </h2>
                  <p :if={@subtitle != []} id={"#{@id}-description"} class="text-caption text-muted">
                    {render_slot(@subtitle)}
                  </p>
                </div>
                {render_slot(@inner_block)}
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
  attr :cancel_text, :string
  attr :confirm_text, :string

  def confirm_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:cancel_text, fn -> gettext("Cancel") end)
      |> assign_new(:confirm_text, fn -> gettext("Delete") end)

    ~H"""
    <.modal id={@id}>
      <:title>{@title}</:title>
      <:subtitle>{@message}</:subtitle>
      <div>
        <!-- Warning Icon -->
        <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-accent-danger to-accent-dangerTo mb-4">
          <i class="fas fa-exclamation-triangle text-strong text-2xl"></i>
        </div>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-2">
          <.button
            phx-click={JS.exec("data-cancel", to: "##{@id}")}
            type="button"
            variant={:secondary}
          >
            {@cancel_text}
          </.button>

          <.button
            phx-click={@confirm_event}
            phx-value-id={@confirm_value}
            type="button"
            variant={:danger}
          >
            <i class="fas fa-trash"></i>
            {@confirm_text}
          </.button>
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
        submit_variant={:info}
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
  attr :submit_label, :string
  attr :cancel_label, :string

  attr :submit_variant, :atom,
    default: :primary,
    values: [:primary, :secondary, :ghost, :danger, :warning, :info, :success]

  slot :inner_block, required: true

  def form_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:submit_label, fn -> gettext("Save") end)
      |> assign_new(:cancel_label, fn -> gettext("Cancel") end)

    ~H"""
    <div
      id={@id}
      phx-hook="ModalFocus"
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="bg-surface-base/80 backdrop-blur-sm fixed inset-0 transition-opacity"
        aria-hidden="true"
      />
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
              class="relative hidden transition"
            >
              <!-- Header -->
              <div class="bg-surface-raised rounded-lg border border-surface-muted/50 shadow-card p-6">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="absolute top-4 right-4 w-8 h-8 rounded-md bg-surface-muted/50 hover:bg-surface-muted flex items-center justify-center transition-all duration-200 group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70"
                  aria-label={gettext("close")}
                >
                  <i class="fas fa-times text-muted group-hover:text-strong text-sm"></i>
                </button>

                <div class="pr-12 mb-4">
                  <h2 id={"#{@id}-title"} class="text-heading font-bold text-strong">
                    {@title}
                  </h2>
                  <p :if={@subtitle} id={"#{@id}-description"} class="text-caption text-muted">
                    {@subtitle}
                  </p>
                </div>

                <!-- Form Content -->
                <div id={"#{@id}-content"}>
                  <.form
                    for={@form}
                    id={"#{@id}-form"}
                    phx-submit={@on_submit}
                    phx-change={@on_change}
                  >
                    <div class="space-y-4">
                      {render_slot(@inner_block)}
                    </div>

                    <!-- Actions -->
                    <div class="mt-6 flex justify-end gap-3 pt-6 border-t border-surface-muted/50">
                      <.button
                        type="button"
                        variant={:secondary}
                        phx-click={JS.exec("data-cancel", to: "##{@id}")}
                      >
                        {@cancel_label}
                      </.button>
                      <.button type="submit" variant={@submit_variant}>
                        <i class="fas fa-save"></i>
                        {@submit_label}
                      </.button>
                    </div>
                  </.form>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_variant("not_started"), do: :secondary
  defp status_variant("in_progress"), do: :warning
  defp status_variant("learned"), do: :success
  defp status_variant(_), do: :secondary

  defp status_icon("not_started"), do: "fa-spinner"
  defp status_icon("in_progress"), do: "fa-spinner"
  defp status_icon("learned"), do: "fa-check-circle"

  defp status_text("not_started"), do: gettext("Learn")
  defp status_text("in_progress"), do: gettext("In Progress")
  defp status_text("learned"), do: gettext("Learned")

  attr :pattern, :map, required: true, doc: "Pattern data"
  attr :current_user, :map, required: false, default: nil, doc: "current user data"
  attr :expanded_pattern_id, :any, required: true, doc: "id of currently expanded pattern"

  attr :expanded_children_id, :any,
    required: false,
    default: nil,
    doc: "id of pattern with expanded children (manual toggle)"

  attr :expanded_children_ids, :any,
    required: false,
    default: nil,
    doc: "MapSet of pattern ids auto-expanded by search"

  attr :status, :string,
    required: false,
    default: nil,
    doc: "current user status for this pattern"

  attr :status_map, :map,
    required: false,
    default: %{},
    doc: "map of pattern_id => status for children"

  attr :locale, :string, required: false, default: "en", doc: "for simple translation"
  attr :is_child, :boolean, default: false

  def pattern(assigns) do
    assigns = assign_new(assigns, :children, fn -> Map.get(assigns.pattern, :children, []) end)

    ~H"""
    <div class={["w-full", if(@is_child, do: "", else: "max-w-4xl md:w-1/2 mb-4")]}>
      <!-- One shared box: parent + toggle + children -->
      <div class={[
        if(@is_child,
          do: "bg-surface-muted/20 border-l-2 border-accent-info/40",
          else:
            "rounded-lg border border-surface-muted/50 bg-surface-raised/50 shadow-card overflow-hidden transition-all duration-300 hover:border-brand-from/30 hover:shadow-lift"
        )
      ]}>
        <!-- Pattern card (no border/rounding of its own) -->
        <div
          id={"pattern-card-#{@pattern.id}"}
          phx-click="toggle_pattern"
          phx-value-id={@pattern.id}
          class={[
            "group w-full cursor-pointer transition-colors duration-200",
            if(@is_child, do: "hover:bg-surface-muted/30", else: "hover:bg-surface-muted/20")
          ]}
        >
          <div class="p-6 flex items-start justify-between">
            <div class="flex-1 min-w-0">
              <div class="flex flex-wrap gap-1 sm:gap-2 mb-2 sm:mb-3">
                <span class="px-2 sm:px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-brand-from/20 to-accent-warningTo/20 text-brand-lightTo border border-accent-info/30">
                  {WcsStudio.DanceType.get_name(@pattern.dance_type, @locale)}
                </span>
                <%= if not @is_child && not Enum.empty?(@children) do %>
                  <span class="px-2 sm:px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-brand-from/20 to-accent-warningTo/20 text-brand-soft border border-brand-from/30">
                    <i class="fas fa-sitemap mr-1"></i>
                    {length(@children)} {gettext("variations")}
                  </span>
                <% end %>
              </div>

              <h2 class="text-3xl font-bold text-strong mb-2 bg-gradient-to-r from-strong to-body bg-clip-text text-transparent">
                {@pattern.name}
              </h2>
            </div>
          </div>

          <!-- Collapsed body preview -->
          <div
            class={if @expanded_pattern_id == @pattern.id, do: "hidden", else: "px-6 pb-4 pt-0"}
            id={"preview-body-#{@pattern.id}"}
          >
            <div class="flex items-center text-subtle text-xs">
              <i class="fas fa-info-circle mr-1"></i>
              <span>{gettext("Click to expand pattern details")}</span>
            </div>
          </div>

          <!-- Expanded content -->
          <div
            id={"expanded-body-#{@pattern.id}"}
            class={
              unless @expanded_pattern_id == @pattern.id,
                do: "hidden",
                else: "px-4 pb-4 pt-0 border-t border-surface-muted/50"
            }
          >
            <div class="py-4">
              <div class="mb-4">
                <div class="p-4 rounded-md bg-surface-muted/30 border border-surface-muted shadow-panel">
                  <div class="flex items-center mb-4">
                    <div class="w-10 h-10 rounded-md bg-gradient-to-br from-accent-amber to-accent-warningHoverFrom flex items-center justify-center mr-3 shadow-panel">
                      <i class="fas fa-list-ul text-strong text-sm"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-strong">{gettext("Description")}</h2>
                  </div>
                  <div class="flex items-baseline gap-2 text-body">
                    <span class="text-caption text-muted">{gettext("Starting position:")}</span>
                    <span class="font-medium text-strong">
                      {WcsStudio.Pattern.hands_label(@pattern.starting_hands)}
                    </span>
                  </div>
                  <div class="flex items-baseline gap-2 text-body">
                    <span class="text-caption text-muted">{gettext("Ending position:")}</span>
                    <span class="font-medium text-strong">
                      {WcsStudio.Pattern.hands_label(@pattern.ending_hands)}
                    </span>
                  </div>
                  <div class="flex items-baseline gap-2 text-body">
                    <span class="text-caption text-muted">{gettext("Count:")}</span>
                    <span class="font-medium text-strong">{@pattern.count_num}</span>
                  </div>
                </div>
              </div>

              <%= if @expanded_pattern_id == @pattern.id do %>
                <div class="rounded-md bg-surface-muted/30 border border-surface-muted shadow-panel">
                  <div class="flex items-center mb-4 pt-4 pl-4 pr-4">
                    <div class="w-10 h-10 rounded-md bg-gradient-to-br from-accent-danger to-accent-warningTo flex items-center justify-center mr-3 shadow-panel">
                      <i class="fas fa-play text-strong text-sm"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-strong">{gettext("Showcase Video")}</h2>
                  </div>
                  <div class="w-full rounded-md shadow-panel overflow-hidden pl-2 pr-2 pb-2">
                    <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                      <iframe
                        class="absolute top-0 left-0 w-full h-full"
                        src={@pattern.video_url}
                        title={gettext("YouTube video player")}
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                        allowfullscreen
                      ></iframe>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>

            <!-- Actions -->
            <div class="flex flex-wrap justify-end gap-2 pt-4 border-t border-surface-muted/50">
              <%= if @current_user do %>
                <% status = @status || "not_started" %>
                <.button
                  phx-click="update_status"
                  phx-value-pattern_id={@pattern.id}
                  phx-value-status={status}
                  variant={status_variant(status)}
                  size={:sm}
                >
                  <i class={"fas #{status_icon(status)}"}></i>
                  {status_text(status)}
                </.button>
              <% end %>

              <%= if @current_user && @current_user.role == "admin" do %>
                <.button
                  phx-click="open_update_modal"
                  phx-value-id={@pattern.id}
                  variant={:info}
                  size={:sm}
                >
                  <i class="fas fa-edit"></i>
                  {gettext("Update")}
                </.button>

                <.button
                  phx-click={show_modal("confirm-delete-pattern-#{@pattern.id}")}
                  variant={:danger}
                  size={:sm}
                >
                  <i class="fas fa-trash"></i>
                  {gettext("Delete")}
                </.button>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Variations (root patterns only), inside the same box -->
        <%= if not @is_child && not Enum.empty?(@children) do %>
          <% children_expanded =
            @expanded_children_id == @pattern.id or
              (not is_nil(@expanded_children_ids) and
                 MapSet.member?(@expanded_children_ids, @pattern.id)) %>

          <button
            phx-click="toggle_children"
            phx-value-id={@pattern.id}
            class={[
              "w-full flex items-center justify-between px-6 py-3 text-sm font-medium transition-colors duration-200 border-t",
              if(children_expanded,
                do: "bg-brand-from/10 text-brand-soft border-brand-from/30 hover:bg-brand-from/20",
                else:
                  "bg-surface-base/30 text-muted border-surface-muted/50 hover:text-brand-soft hover:bg-brand-from/10"
              )
            ]}
          >
            <span>
              <i class="fas fa-sitemap mr-2"></i>
              {length(@children)} {gettext("variations of")} {@pattern.name}
            </span>
            <i class={[
              "fas text-xs",
              if(children_expanded, do: "fa-chevron-up", else: "fa-chevron-down")
            ]}></i>
          </button>

          <%= if children_expanded do %>
            <div class="rounded-b-lg overflow-hidden border-t border-surface-muted/50 divide-y divide-surface-muted/30">
              <%= for child <- @children do %>
                <.pattern
                  pattern={child}
                  is_child={true}
                  expanded_pattern_id={@expanded_pattern_id}
                  expanded_children_id={@expanded_children_id}
                  expanded_children_ids={@expanded_children_ids}
                  current_user={@current_user}
                  status={Map.get(@status_map, child.id)}
                  status_map={@status_map}
                  locale={@locale}
                />
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>

      <!-- Child delete modals live OUTSIDE the box so overflow-hidden can't clip them -->
      <%= if !@is_child && @current_user && @current_user.role == "admin" do %>
        <%= for child <- @children do %>
          <.confirm_modal
            id={"confirm-delete-pattern-#{child.id}"}
            title={gettext("Delete Pattern?")}
            message={
              gettext(
                "Are you sure you want to delete '%{name}'? This action cannot be undone and will remove all associated data.",
                name: child.name
              )
            }
            confirm_event="delete_pattern"
            confirm_value={child.id}
          />
        <% end %>
      <% end %>
    </div>
    """
  end

  defp attended_variant(false), do: :secondary
  defp attended_variant(true), do: :success

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
    <div
      id={"lesson-card-#{@lesson.id}"}
      phx-click="toggle_lesson"
      phx-value-id={@lesson.id}
      class="group bg-surface-raised/50 backdrop-blur-sm rounded-lg border border-surface-muted/50 shadow-card transition-all duration-300 mb-6 cursor-pointer hover:shadow-lift hover:border-brand-from/30 max-w-4xl md:w-1/2"
    >
      <div class="p-6 flex items-start justify-between">
        <div class="flex-1 min-w-0">
          <div class="flex flex-wrap gap-2 mb-3">
            <span class="px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-brand-from/20 to-brand-to/20 text-brand-lightTo border border-accent-info/30">
              <i class="fas fa-music mr-1"></i>
              {WcsStudio.DanceType.get_name(@lesson.dance_type, @locale)}
            </span>
            <span class="px-3 py-1 rounded-full text-xs font-medium bg-gradient-to-r from-accent-success/20 to-accent-successTo/20 text-accent-success border border-accent-success/30">
              <i class="fas fa-chart-line mr-1"></i>
              {@lesson.level.name}
            </span>
          </div>
          <h2 class="text-2xl font-bold text-strong mb-3 bg-gradient-to-r from-strong to-body bg-clip-text text-transparent">
            {@lesson.title}
          </h2>
          <div class="flex  text-sm text-muted gap-8">
            <div class="flex items-center whitespace-nowrap">
              <i class="fas fa-calendar-day mr-2 text-accent-info"></i>
              <span>{@lesson.date}</span>
            </div>
            <div class="flex items-center">
              <i class="fas fa-map-marker-alt mr-2 text-accent-danger"></i>
              <span>{@lesson.place}</span>
            </div>
          </div>
        </div>
        <div class="flex-shrink-0 transition-transform duration-300 ml-4 group">
          <div class="w-12 h-12 rounded-md bg-gradient-to-br from-accent-info to-accent-infoTo flex items-center justify-center shadow-panel">
            <i class={[
              "fas fa-chevron-down text-strong transition-transform duration-300",
              if(@expanded_lesson_id == @lesson.id, do: "rotate-180", else: "group-hover:rotate-180")
            ]}></i>
          </div>
        </div>
      </div>

      <!-- Collapsed body preview -->
      <div
        class={if @expanded_lesson_id == @lesson.id, do: "hidden", else: "px-6 pb-4 pt-0 "}
        id={"preview-body-#{@lesson.id}"}
      >
        <div class="flex items-center text-sm text-muted">
          <span>
            <i class="fas fa-users mr-1"></i>
            {ngettext("1 instructor", "%{count} instructors", length(@lesson.instructors))}
          </span>
        </div>
      </div>

      <!-- Expanded content -->
      <div
        class={
          unless @expanded_lesson_id == @lesson.id,
            do: "hidden",
            else: "px-2 pb-4 pt-0 border-t border-surface-muted/50 mt-4"
        }
        id={"expanded-body-#{@lesson.id}"}
      >
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-4 pt-4">
          <!-- Patterns Box -->
          <div class="p-4 rounded-md bg-surface-muted/30 backdrop-blur-sm border border-surface-muted shadow-panel">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-md bg-gradient-to-br from-accent-info to-accent-infoTo flex items-center justify-center mr-3 shadow-panel">
                <i class="fas fa-shapes text-strong text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-strong">{gettext("Patterns")}</h2>
            </div>
            <div class="space-y-3">
              <%= for pattern <- @lesson.patterns do %>
                <div class="bg-surface-muted/40 p-3 rounded-lg flex items-center">
                  <i class="fas fa-circle text-accent-info text-xs mr-3 animate-pulse"></i>
                  <span class="font-medium text-body">{pattern.name}</span>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Instructors Box -->
          <div class="p-4 rounded-md bg-surface-muted/30 backdrop-blur-sm border border-surface-muted shadow-panel">
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 rounded-md bg-gradient-to-br from-brand-from to-brand-to flex items-center justify-center mr-3 shadow-panel">
                <i class="fas fa-users text-strong text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-strong">{gettext("Instructors")}</h2>
            </div>
            <div class="space-y-4">
              <%= for instructor <- @lesson.instructors do %>
                <div class="flex items-center p-3 rounded-lg bg-surface-muted/40 ">
                  <div class="w-12 h-12 rounded-md bg-gradient-to-br from-brand-from to-brand-to flex items-center justify-center mr-3 shadow-panel">
                    <span class="font-bold text-strong text-sm">
                      {String.first(instructor.username)}
                    </span>
                  </div>
                  <div>
                    <h3 class="font-semibold text-strong">{instructor.username}</h3>
                    <p class="text-sm text-muted">{gettext("Dance Instructor")}</p>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Video Section -->
        <%= if @expanded_lesson_id == @lesson.id do %>
          <div class="rounded-md bg-surface-muted/30 backdrop-blur-sm border border-surface-muted shadow-panel">
            <div class="flex items-center mb-4 pt-4 pl-4 pr-4">
              <div class="w-10 h-10 rounded-md bg-gradient-to-br from-accent-danger to-accent-dangerTo flex items-center justify-center mr-3 shadow-panel">
                <i class="fas fa-play text-strong text-sm"></i>
              </div>
              <h2 class="text-xl font-bold text-strong">{gettext("Video Lesson")}</h2>
            </div>
            <div class="w-full rounded-md shadow-panel overflow-hidden">
              <div class="relative" style="padding-bottom: 56.25%; height: 0;">
                <iframe
                  class="absolute top-0 left-0 w-full h-full"
                  src={@lesson.lesson_vid_url}
                  title={gettext("YouTube video player")}
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen
                ></iframe>
              </div>
            </div>
          </div>
        <% end %>

        <!-- Actions -->
        <div class="flex flex-wrap justify-end gap-2 mt-4 pt-4 border-t border-surface-muted/50">
          <%= if @current_user do %>
            <% attended = @attended || false %>
            <.button
              phx-click="toggle_attendance"
              phx-value-lesson_id={@lesson.id}
              phx-value-user_id={@current_user.id}
              phx-value-attended={attended}
              variant={attended_variant(attended)}
              size={:sm}
            >
              <i class={"fas #{attended_icon(attended)}"}></i>
              {attended_text(attended)}
            </.button>
          <% end %>

          <%= if @current_user && @current_user.role == "admin" do %>
            <.button
              phx-click="open_update_modal"
              phx-value-id={@lesson.id}
              variant={:info}
            >
              <i class="fas fa-edit"></i>
              {gettext("Update Lesson")}
            </.button>

            <.button
              phx-click={show_modal("confirm-delete-lesson-#{@lesson.id}")}
              variant={:danger}
              size={:sm}
            >
              <i class="fas fa-trash"></i>
              {gettext("Delete")}
            </.button>
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
      class="block group bg-surface-raised/50 backdrop-blur-sm rounded-lg border border-surface-muted/50 shadow-card transition-all duration-500 hover:shadow-lift hover:border-brand-from/30  overflow-hidden"
    >
      <div class="p-8">
        <div class="flex items-center gap-2 mb-4">
          <span class="px-3 py-1 rounded-full text-sm bg-surface-muted/50 text-body border border-surface-muted backdrop-blur-sm">
            {WcsStudio.Post.estimate_read_time(@post.body)}
          </span>
        </div>

        <h2 class="text-2xl font-bold text-strong mb-4 group-hover:text-transparent group-hover:bg-gradient-to-r group-hover:from-brand-from group-hover:to-brand-to group-hover:bg-clip-text transition-all duration-300">
          {@post.title}
        </h2>

        <p class="text-body leading-relaxed mb-6 line-clamp-3">
          {@post.body}
        </p>

        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <img
              src={avatar_url(@post.user.profile_pic_url)}
              class="w-10 h-10 rounded-md bg-gradient-to-br from-brand-from to-brand-to p-0.5"
              alt={@post.user.username}
            />
            <div>
              <p class="font-medium text-strong">{@post.user.username}</p>
              <p class="text-sm text-muted">
                <%= if @post.inserted_at do %>
                  {Calendar.strftime(@post.inserted_at, "%b %d, %Y")}
                <% else %>
                  {gettext("Unknown date")}
                <% end %>
              </p>
            </div>
          </div>
          <div class="flex items-center gap-6 text-muted">
            <div class="flex items-center gap-2 group-hover:text-brand-lightFrom transition-colors">
              <i class="fas fa-arrow-right"></i>
              <span>{gettext("Read more")}</span>
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

  attr :kind, :atom,
    values: [:info, :error, :warning, :success],
    doc: "used for styling and flash lookup"

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
        "fixed top-16 right-4 z-50 rounded-lg p-4 backdrop-blur-sm border shadow-card max-w-sm transform transition-all duration-300 cursor-pointer group hover:-translate-y-1 hover:shadow-lift",
        @kind == :info &&
          "bg-surface-raised/80 border-accent-info/30 text-accent-info shadow-accent-info/10 hover:border-accent-info/50",
        @kind == :error &&
          "bg-surface-raised/80 border-accent-danger/30 text-accent-danger shadow-accent-danger/10 hover:border-accent-danger/50",
        @kind == :warning &&
          "bg-surface-raised/80 border-accent-warning/30 text-accent-warning shadow-accent-warning/10 hover:border-accent-warning/50",
        @kind == :success &&
          "bg-surface-raised/80 border-accent-success/30 text-accent-success shadow-accent-success/10 hover:border-accent-success/50"
      ]}
      phx-mounted={JS.dispatch("flash:mounted", to: "##{@id}")}
      {@rest}
    >
      <div class="flex items-start gap-3">
        <!-- Icon Container -->
        <div class={[
          "flex-shrink-0 w-10 h-10 rounded-md flex items-center justify-center shadow-panel",
          @kind == :info && "bg-gradient-to-br from-accent-infoTo to-accent-info",
          @kind == :error && "bg-gradient-to-br from-accent-danger to-accent-dangerTo",
          @kind == :warning && "bg-gradient-to-br from-accent-warning to-accent-warningTo",
          @kind == :success && "bg-gradient-to-br from-accent-successTo to-accent-success"
        ]}>
          <i class={[
            "text-strong text-sm",
            @kind == :info && "fas fa-info-circle",
            @kind == :error && "fas fa-exclamation-triangle",
            @kind == :warning && "fas fa-exclamation-circle",
            @kind == :success && "fas fa-check-circle"
          ]}></i>
        </div>

        <!-- Content -->
        <div class="flex-1 min-w-0">
          <p :if={@title} class="font-semibold text-strong text-sm leading-6 mb-1">
            {@title}
          </p>
          <p class="text-sm leading-5 opacity-90">{msg}</p>
        </div>

        <!-- Close Button -->
        <button
          type="button"
          phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
          class="flex-shrink-0 w-8 h-8 rounded-md bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200 group-hover:scale-110 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70"
          aria-label={gettext("close")}
        >
          <i class="fas fa-times text-xs text-strong/70 group-hover:text-strong"></i>
        </button>
      </div>

      <!-- Progress Bar -->
      <div class={[
        "w-full h-1 rounded-full mt-3 overflow-hidden",
        @kind == :info && "bg-accent-info/20",
        @kind == :error && "bg-accent-danger/20",
        @kind == :warning && "bg-accent-warning/20",
        @kind == :success && "bg-accent-success/20"
      ]}>
        <div
          class={[
            "h-full rounded-full progress-bar",
            @kind == :info && "bg-gradient-to-r from-accent-infoLight to-accent-infoLightTo",
            @kind == :error && "bg-gradient-to-r from-accent-dangerLight to-accent-dangerLightTo",
            @kind == :warning && "bg-gradient-to-r from-accent-warningLight to-accent-warningLightTo",
            @kind == :success && "bg-gradient-to-r from-accent-successLight to-accent-successLightTo"
          ]}
          style="width: 0"
        >
        </div>
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
        {gettext("Attempting to reconnect")}
        <.icon name="fa-spinner" class="ml-1 fa-spin text-xs" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="fa-spinner" class="ml-1 fa-spin text-xs" />
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
        {render_slot(@inner_block, f)}
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          {render_slot(action, f)}
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button with the shared brand variants and sizes.

  Pass `href` to render a link with the same styling (useful for CTAs).

  ## Examples

      <.button>Send!</.button>
      <.button variant={:primary} size={:lg}>Get started</.button>
      <.button href={~p"/users/log_in"} variant={:secondary}>Log in</.button>
  """
  attr :type, :string, default: nil
  attr :href, :string, default: nil, doc: "renders a link styled as a button when set"

  attr :variant, :atom,
    default: :primary,
    values: [:primary, :secondary, :ghost, :danger, :warning, :info, :success]

  attr :size, :atom, default: :md, values: [:sm, :md, :lg]
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to apply to the button"

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <.link :if={@href} href={@href} class={button_classes(assigns)} {@rest}>
      {render_slot(@inner_block)}
    </.link>
    <button :if={!@href} type={@type} disabled={@disabled} class={button_classes(assigns)} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp button_classes(%{variant: variant, size: size, disabled: disabled, class: class}) do
    [
      "phx-submit-loading:opacity-75 inline-flex items-center justify-center gap-2 font-semibold rounded-sm transition-all duration-300",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70 focus-visible:ring-offset-2 focus-visible:ring-offset-surface-base",
      button_variant(variant),
      button_size(size),
      disabled && "opacity-50 cursor-not-allowed hover:translate-y-0",
      class
    ]
  end

  defp button_variant(:primary),
    do:
      "bg-gradient-to-r from-brand-from to-brand-to text-strong shadow-raised hover:shadow-glow hover:-translate-y-0.5"

  defp button_variant(:secondary),
    do:
      "bg-surface-muted/50 backdrop-blur-sm border border-surface-muted text-strong hover:bg-surface-muted hover:border-strong"

  defp button_variant(:ghost),
    do: "bg-transparent text-body hover:bg-surface-raised/50 hover:text-strong"

  defp button_variant(:danger),
    do:
      "bg-gradient-to-r from-accent-danger to-accent-dangerTo hover:from-accent-dangerHoverFrom hover:to-accent-dangerHoverTo text-strong shadow-raised hover:shadow-accent-danger/25 hover:-translate-y-0.5"

  defp button_variant(:info),
    do:
      "bg-gradient-to-r from-accent-info to-accent-infoTo hover:from-accent-infoHoverFrom hover:to-accent-infoHoverTo text-strong shadow-raised hover:shadow-accent-info/25 hover:-translate-y-0.5"

  defp button_variant(:warning),
    do:
      "bg-gradient-to-r from-accent-warning to-accent-warningTo hover:from-accent-warningHoverFrom hover:to-accent-warningHoverTo text-strong shadow-raised hover:shadow-accent-warning/25 hover:-translate-y-0.5"

  defp button_variant(:success),
    do:
      "bg-gradient-to-r from-accent-success to-accent-successTo hover:from-accent-successHoverFrom hover:to-accent-successHoverTo text-strong shadow-raised hover:shadow-accent-success/50 hover:-translate-y-0.5"

  defp button_size(:sm), do: "px-3 py-2 text-sm"
  defp button_size(:md), do: "px-4 py-2 text-sm"
  defp button_size(:lg), do: "px-6 py-3 text-base"

  @doc """
  Renders a surface card with the shared radius, shadow and hover treatment.

  ## Examples

      <.card padding={:lg} interactive>
        Card content
      </.card>
  """
  attr :padding, :atom, default: :md, values: [:none, :sm, :md, :lg]
  attr :interactive, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to apply to the card"

  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div
      class={[
        "rounded-lg bg-surface-raised/50 backdrop-blur-sm border border-surface-muted/50 shadow-card transition-all duration-300",
        card_padding(@padding),
        @interactive && "hover:-translate-y-1 hover:border-brand-from/40 hover:shadow-lift",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp card_padding(:none), do: nil
  defp card_padding(:sm), do: "p-4"
  defp card_padding(:md), do: "p-6"
  defp card_padding(:lg), do: "p-8"

  @doc """
  Renders a linked feature card with an image, icon badge and call to action.

  ## Examples

      <.feature_card
        href={~p"/patterns"}
        image={~p"/images/boots.webp"}
        icon="fas fa-shapes"
        title="Steps"
        description="Explore complex patterns"
        cta="Learn more"
      />
  """
  attr :href, :string, required: true
  attr :image, :string, required: true
  attr :image_alt, :string, default: ""
  attr :icon, :string, required: true, doc: "Font Awesome classes, e.g. \"fas fa-music\""
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :cta, :string, required: true
  attr :class, :string, default: nil

  def feature_card(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "group relative flex flex-col min-h-80 rounded-lg overflow-hidden border border-surface-muted/30 shadow-card transition-all duration-500",
        "hover:-translate-y-1 hover:border-brand-from/40 hover:shadow-lift focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70",
        @class
      ]}
    >
      <div class="absolute inset-0 bg-surface-raised/50 backdrop-blur-sm"></div>
      <div class="absolute inset-0 bg-gradient-to-br from-brand-from/10 via-brand-to/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500">
      </div>

      <div class="relative aspect-video max-h-64 w-full shrink-0 overflow-hidden">
        <div class="absolute top-0 right-0 w-32 h-32 bg-brand-from rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500">
        </div>
        <div class="absolute bottom-0 left-0 w-32 h-32 bg-brand-to rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500">
        </div>
        <div class="absolute inset-0 bg-gradient-to-b from-surface-base/70 to-transparent z-10"></div>
        <img
          src={@image}
          alt={@image_alt}
          loading="lazy"
          decoding="async"
          class="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-700"
        />
        <div class="absolute top-4 left-4 w-12 h-12 rounded-md bg-gradient-to-br from-brand-from to-brand-to flex items-center justify-center shadow-panel group-hover:scale-110 transition-transform duration-300 z-20">
          <i class={[@icon, "text-strong text-lg"]}></i>
        </div>
      </div>

      <div class="relative flex-1 flex flex-col justify-between p-6 z-10">
        <div>
          <h3 class="text-xl font-bold text-strong mb-2 group-hover:text-brand-lightFrom transition-colors duration-300">
            {@title}
          </h3>
          <p class="text-body text-sm leading-relaxed line-clamp-2">{@description}</p>
        </div>
        <div class="flex items-center justify-between pt-3 border-t border-surface-muted group-hover:border-strong/50 transition-colors duration-300">
          <span class="text-brand-lightFrom text-sm font-medium flex items-center gap-2 group-hover:gap-3 transition-all duration-300">
            {@cta}
            <i class="fas fa-arrow-right group-hover:translate-x-1 transition-transform duration-300"></i>
          </span>
        </div>
      </div>
    </.link>
    """
  end

  @doc """
  Renders an empty state with a themed icon badge, title and optional description.
  """
  attr :icon, :string, required: true, doc: "Font Awesome classes, e.g. \"fas fa-music\""
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :compact, :boolean, default: false
  attr :class, :string, default: nil

  slot :actions

  def empty_state(assigns) do
    ~H"""
    <div class={["text-center py-section-sm", @class]}>
      <div class={[
        "mx-auto mb-4 rounded-full bg-surface-raised/50 flex items-center justify-center",
        @compact && "w-16 h-16",
        !@compact && "w-24 h-24"
      ]}>
        <i class={[@icon, @compact && "text-2xl", !@compact && "text-3xl", "text-muted"]}></i>
      </div>
      <h3 class="text-heading-sm font-semibold text-body mb-2">{@title}</h3>
      <p :if={@description} class="text-subtle">{@description}</p>
      <div :if={@actions != []} class="mt-6 flex justify-center">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  @doc """
  Renders animated placeholder bars for content that is still loading.
  """
  attr :lines, :integer, default: 3
  attr :class, :string, default: nil

  def skeleton(assigns) do
    ~H"""
    <div class={["animate-pulse space-y-3", @class]} aria-hidden="true">
      <%= for index <- 1..@lines do %>
        <div class={[
          "h-4 rounded-sm bg-surface-muted/60",
          rem(index, 3) == 0 && "w-2/3",
          rem(index, 3) != 0 && "w-full"
        ]}>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a navigation link with the shared hover underline (desktop) or
  surface treatment (mobile).

  ## Examples

      <.nav_link href={~p"/patterns"}>Steps</.nav_link>
      <.nav_link href={~p"/blog"} mobile>Blog</.nav_link>
  """
  attr :href, :string, required: true
  attr :mobile, :boolean, default: false
  attr :active, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, doc: "the arbitrary HTML attributes to apply to the link"

  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      href={@href}
      class={nav_link_classes(assigns)}
      data-nav-path={@href}
      aria-current={@active && "page"}
      {@rest}
    >
      {render_slot(@inner_block)}
      <span
        :if={!@mobile}
        class={[
          "absolute bottom-0 left-1/2 h-0.5 bg-gradient-to-r from-brand-from to-brand-to transition-all duration-300",
          "w-0 group-hover:w-full group-hover:left-0",
          "aria-[current=page]:w-full aria-[current=page]:left-0"
        ]}
      ></span>
    </.link>
    """
  end

  defp nav_link_classes(%{mobile: true, class: class}) do
    [
      "block px-3 py-3 rounded-sm text-base font-medium border transition-all duration-300",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70",
      "text-body hover:text-strong hover:bg-surface-raised/50 border-transparent hover:border-surface-muted",
      "aria-[current=page]:bg-brand-from/10 aria-[current=page]:text-brand-lightFrom aria-[current=page]:border-brand-from/30",
      class
    ]
  end

  defp nav_link_classes(%{mobile: false, class: class}) do
    [
      "relative px-4 py-2 text-sm font-medium transition-all duration-300 group",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70",
      "text-body hover:text-strong",
      "aria-[current=page]:text-strong",
      class
    ]
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
  attr :value, :any, default: nil

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
    |> assign(:value, field.value)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-3 text-sm leading-6 text-strong">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[
            "rounded border-strong bg-surface-raised/50 text-brand-from focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70 transition-all duration-300",
            "checked:bg-brand-from checked:border-brand-from hover:border-brand-lightFrom/50",
            "w-4 h-4",
            @errors == [] && "border-strong focus:border-brand-from",
            @errors != [] && "border-accent-danger focus:border-accent-danger"
          ]}
          {@rest}
        />
        <span class="text-body hover:text-strong transition-colors duration-200">{@label}</span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id} class="text-strong font-medium mb-2 block">{@label}</.label>
      <select
        id={@id}
        name={@name}
        class={[
          "block w-full rounded-lg text-strong focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
          "phx-no-feedback:border-surface-muted phx-no-feedback:focus:border-brand-from/50",
          "bg-surface-raised/50 border border-surface-muted px-4 py-3",
          @errors == [] && "border-surface-muted focus:border-brand-from/50",
          @errors != [] && "border-accent-danger focus:border-accent-danger"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <.error :for={msg <- @errors} class="mt-2 text-sm text-accent-danger">{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "block w-full rounded-lg text-strong placeholder:text-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
          "min-h-[6rem] phx-no-feedback:border-surface-muted phx-no-feedback:focus:border-brand-from/50",
          "bg-surface-raised/50 border border-surface-muted",
          @errors == [] && "border-surface-muted focus:border-brand-from/50",
          @errors != [] && "border-accent-danger focus:border-accent-danger"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}>{@label}</.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "block w-full rounded-lg text-strong placeholder:text-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-lightFrom/70 sm:text-sm sm:leading-6 transition-all duration-300 backdrop-blur-sm",
          "phx-no-feedback:border-surface-muted phx-no-feedback:focus:border-brand-from/50",
          "bg-surface-raised/50 border border-surface-muted px-4 py-3",
          @errors == [] && "border-surface-muted focus:border-brand-from/50",
          @errors != [] && "border-accent-danger focus:border-accent-danger"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true
  attr :class, :string, default: nil

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-strong font-medium mb-2">
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true
  attr :class, :string, default: nil

  def error(assigns) do
    ~H"""
    <p class={[
      "mt-3 flex gap-3 text-sm leading-6 text-accent-danger phx-no-feedback:hidden",
      @class
    ]}>
      <.icon name="fa-circle-exclamation" class="mt-1 text-lg flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a page header with a title, optional subtitle and actions.

  Use `size={:lg}` with `gradient` and `centered` for the full-width page headers.
  """
  attr :class, :string, default: nil
  attr :size, :atom, default: :md, values: [:md, :lg]
  attr :gradient, :boolean, default: false
  attr :centered, :boolean, default: false
  attr :rest, :global, doc: "additional attributes for the title element"

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[
      @actions != [] && "flex items-center justify-between gap-6",
      @centered && "text-center mb-12 px-4",
      @class
    ]}>
      <div class={[@centered && "mx-auto"]}>
        <h1
          class={[
            "font-bold bg-clip-text text-transparent",
            header_title_size(@size),
            header_title_gradient(@gradient),
            @size == :lg && "mb-6 py-2",
            @size != :lg && "mb-4"
          ]}
          {@rest}
        >
          {render_slot(@inner_block)}
        </h1>
        <p
          :if={@subtitle != []}
          class={["text-muted", @size == :lg && "text-lead max-w-2xl mx-auto"]}
        >
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  defp header_title_size(:lg), do: "text-display-sm md:text-display"
  defp header_title_size(:md), do: "text-heading"

  defp header_title_gradient(true), do: "bg-gradient-to-r from-brand-from to-brand-to"
  defp header_title_gradient(false), do: "bg-gradient-to-r from-strong to-body"

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
        <thead class="text-sm text-left leading-6 text-subtle">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">{col[:label]}</th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-surface-muted/50 border-t border-surface-muted/50 text-sm leading-6 text-body"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="group hover:bg-surface-muted/50"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-surface-muted/50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-strong"]}>
                  {render_slot(col, @row_item.(row))}
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-surface-muted/50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-strong hover:text-body"
                >
                  {render_slot(action, @row_item.(row))}
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
      <dl class="-my-4 divide-y divide-surface-muted/50">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-subtle">{item.title}</dt>
          <dd class="text-body">{render_slot(item)}</dd>
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
        class="text-sm font-semibold leading-6 text-strong hover:text-body"
      >
        <.icon name="fa-arrow-left" class="text-xs" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Font Awesome](https://fontawesome.com) icon using the solid style.

  Pass the icon class name (without the `fas` prefix) in `name`, and use
  Tailwind text-size/color utilities or Font Awesome modifiers in `class`.

  ## Examples

      <.icon name="fa-xmark" />
      <.icon name="fa-spinner" class="fa-spin ml-1 text-xs" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(assigns) do
    ~H"""
    <i class={["fas", @name, @class]}></i>
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
  end

  @doc """
  Returns a profile picture URL that always resolves from the site root.

  Some stored avatar paths are relative (for example `images/user_icon.png`).
  A relative `src` is resolved against the current URL, so it breaks on nested
  routes such as `/admin/lessons` (the browser requests
  `/admin/images/user_icon.png`). Absolute URLs and data URIs are left intact.
  """
  def avatar_url(url), do: image_url(url, @default_avatar_url)

  @doc """
  Returns an image URL that always resolves from the site root.

  Relative paths (for example `images/West-coast-swing.webp`) are resolved by
  the browser against the current route, which breaks on nested paths such as
  `/admin/lessons`. Blank values fall back to `fallback`.
  """
  def image_url(url, fallback) when is_binary(url) do
    url = String.trim(url)

    cond do
      url == "" -> fallback
      Regex.match?(~r/^(?:[a-z][a-z0-9+.-]*:|\/\/|\/)/i, url) -> url
      true -> "/" <> url
    end
  end

  def image_url(_, fallback), do: fallback

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
