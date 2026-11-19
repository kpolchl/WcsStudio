defmodule WcsStudioWeb.DanceTypesLive do
  use WcsStudioWeb, :live_view
  alias WcsStudio.DanceType

  @default_image "/images/dance-971082_1280.webp"
  @types ~w(latin swing social standard)

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        dance_types: DanceType.get_all(),
        selected_dance_type_type: "all",
        form: to_form(Ecto.Changeset.change(%DanceType{})),
        modal_state: nil,
        default_image: @default_image,
        types: @types
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("select_type_type", %{"dance_type_type" => dance_type_type}, socket) do
    {:noreply,
     socket
     |> assign(:selected_dance_type_type, dance_type_type)
     |> assign(:dance_types, get_dance_types_by_type(dance_type_type))}
  end

  @impl true
  def handle_event("open_modal", _, socket) do
    if admin?(socket) do
      {:noreply,
       assign(socket,
         modal_state: :create,
         form: to_form(Ecto.Changeset.change(%DanceType{}))
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, modal_state: nil)}
  end

  def handle_event("validate", _params, socket), do: {:noreply, socket}

  def handle_event("save", %{"dance_type" => dance_type_params}, socket) do
    if admin?(socket) do
      case DanceType.add(dance_type_params) do
        {:ok, _dance_type} ->
          {:noreply,
           socket
           |> assign(
             modal_state: nil,
             dance_types: DanceType.get_all(),
             selected_dance_type_type: "all"
           )
           |> put_flash(:success, "Dance type created successfully!")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    else
      {:noreply, socket}
    end
  end

  defp admin?(%{assigns: %{current_user: %{role: "admin"}}}), do: true
  defp admin?(_), do: false

  defp get_dance_types_by_type("all"), do: DanceType.get_all()
  defp get_dance_types_by_type(type), do: DanceType.get_by_type(type)

  @impl true
  def render(assigns) do
    ~H"""
    <.header
      size={:lg}
      gradient
      centered
      style="-webkit-text-fill-color: transparent;"
    >
      {gettext("Dance Types")}
      <:subtitle>
        {gettext(
          "Browse through variable dance styles, from around the world that admin is learning or already knows."
        )}
      </:subtitle>
    </.header>

    <!-- Add Dance Type Button (Admin Only) -->
    <%= if @current_user && @current_user.role == "admin" do %>
      <div class="w-full max-w-2xl mx-auto px-4 mb-8">
        <.button phx-click="open_modal" class="w-full sm:w-auto">
          <i class="fas fa-plus"></i>
          <span>{gettext("Add New Dance Type")}</span>
        </.button>
      </div>
    <% end %>

    <!-- Enhanced Filter System -->
    <section class="px-4 mb-16">
      <div class="max-w-6xl mx-auto">
        <!-- Style Filters -->
        <div class="flex flex-wrap justify-center gap-3 mb-8">
          <button
            type="button"
            phx-click="select_type_type"
            phx-value-dance_type_type="all"
            class={[
              "px-6 py-3 rounded-md font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "all" do
                "bg-gradient-to-r from-brand-from to-brand-to text-white shadow-raised shadow-brand-from/25"
              else
                "bg-surface-raised/50 hover:bg-surface-muted/50 text-slate-300 border border-surface-muted/50"
              end
            ]}
          >
            <i class="fas fa-layer-group mr-2"></i> {gettext("All Styles")}
          </button>

          <button
            type="button"
            phx-click="select_type_type"
            phx-value-dance_type_type="latin"
            class={[
              "px-6 py-3 rounded-md font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "latin" do
                "bg-gradient-to-r from-brand-from to-brand-to text-white shadow-raised shadow-brand-from/25"
              else
                "bg-surface-raised/50 hover:bg-surface-muted/50 text-slate-300 border border-surface-muted/50"
              end
            ]}
          >
            <i class="fas fa-fire mr-2 "></i> {gettext("Latin")}
          </button>

          <button
            type="button"
            phx-click="select_type_type"
            phx-value-dance_type_type="swing"
            class={[
              "px-6 py-3 rounded-md font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "swing" do
                "bg-gradient-to-r from-brand-from to-brand-to text-white shadow-raised shadow-brand-from/25"
              else
                "bg-surface-raised/50 hover:bg-surface-muted/50 text-slate-300 border border-surface-muted/50"
              end
            ]}
          >
            <i class="fas fa-sync-alt mr-2"></i> {gettext("Swing")}
          </button>

          <button
            type="button"
            phx-click="select_type_type"
            phx-value-dance_type_type="social"
            class={[
              "px-6 py-3 rounded-md font-medium transition-all duration-300 flex items-center",
              if @selected_dance_type_type == "social" do
                "bg-gradient-to-r from-brand-from to-brand-to text-white shadow-raised shadow-brand-from/25"
              else
                "bg-surface-raised/50 hover:bg-surface-muted/50 text-slate-300 border border-surface-muted/50"
              end
            ]}
          >
            <i class="fas fa-users mr-2"></i> {gettext("Social")}
          </button>
        </div>
      </div>
    </section>

    <!--Card Grid -->
    <section class="px-4 pb-16">
      <div class="max-w-7xl mx-auto">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <%= for dance_type <- @dance_types do %>
            <.link
              navigate={~p"/patterns?dance_type_id=#{dance_type.id}"}
              class="group relative flex flex-col h-80 rounded-lg overflow-hidden transition-all duration-500 hover:-translate-y-2 hover:shadow-card border border-surface-muted/30 hover:border-surface-muted"
            >
              <!-- Background -->
              <div
                class="absolute inset-0 bg-surface-raised/50 backdrop-blur-sm"
                style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
              >
              </div>
              <div class="absolute inset-0 bg-gradient-to-br from-brand-from/10 via-brand-to/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500">
              </div>

              <!-- Image Section (Top 60%) -->
              <div class="relative h-3/5 overflow-hidden">
                <!-- Background Effects -->
                <div class="absolute top-0 right-0 w-32 h-32 bg-brand-from rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500">
                </div>
                <div class="absolute bottom-0 left-0 w-32 h-32 bg-brand-to rounded-full blur-3xl opacity-20 group-hover:opacity-30 transition-opacity duration-500">
                </div>

                <!-- Gradient Overlay -->
                <div class="absolute inset-0 bg-gradient-to-b from-surface-base/70 to-transparent z-10">
                </div>

                <!-- Image -->
                <img
                  src={image_url(dance_type.pic_url, @default_image)}
                  alt={"#{DanceType.get_name(dance_type, @locale)} dance style"}
                  loading="lazy"
                  class="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-700"
                />
              </div>

              <!-- Content Section (Bottom 40%) -->
              <div class="relative flex-1 flex flex-col justify-between p-6 z-10">
                <div>
                  <h3 class="text-xl font-bold text-white mb-2 group-hover:text-brand-lightFrom transition-colors duration-300">
                    {DanceType.get_name(dance_type, @locale)}
                  </h3>
                  <p class="text-slate-300 text-sm leading-relaxed line-clamp-2 flex items-center">
                    <i class="fas fa-globe-americas mr-2 text-brand-lightFrom"></i>
                    {DanceType.get_country(dance_type, @locale)}
                  </p>
                </div>

                <!-- CTA -->
                <div class="flex items-center justify-between pt-3 border-t border-surface-muted group-hover:border-slate-500/50 transition-colors duration-300">
                  <span
                    class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-white/10 text-white backdrop-blur-sm border border-white/20"
                    style="backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
                  >
                    <i class="fas fa-tag mr-1"></i>
                    {dance_type.type}
                  </span>
                  <span class="text-brand-lightFrom text-sm font-medium flex items-center gap-2 group-hover:gap-3 transition-all duration-300">
                    {gettext("Explore")}
                    <i class="fas fa-arrow-right group-hover:translate-x-1 transition-transform duration-300"></i>
                  </span>
                </div>
              </div>
            </.link>
          <% end %>
        </div>

        <!-- Empty State -->
        <%= if Enum.empty?(@dance_types) do %>
          <.empty_state
            icon="fas fa-music"
            title={gettext("No dance types found ")}
            description={gettext("Try selecting a different filter")}
          />
        <% end %>
      </div>
    </section>

    <!-- Modals -->
    <%= case @modal_state do %>
      <% :create -> %>
        <.form_modal
          id="new-dance-type-modal"
          show={true}
          title={gettext("New Dance Type")}
          subtitle={gettext("Fill out the form to add a new dance type")}
          form={@form}
          on_cancel={JS.push("close_modal")}
          on_submit="save"
        >
          <.input type="text" field={@form[:name_en]} label={gettext("Name (English)")} />
          <.input type="text" field={@form[:name_pl]} label={gettext("Name (Polish)")} />
          <.input
            type="textarea"
            field={@form[:description_en]}
            label={gettext("Description (English)")}
          />
          <.input
            type="textarea"
            field={@form[:description_pl]}
            label={gettext("Description (Polish)")}
          />
          <.input type="text" field={@form[:country_en]} label={gettext("Country (English)")} />
          <.input type="text" field={@form[:country_pl]} label={gettext("Country (Polish)")} />
          <.input type="text" field={@form[:tag_en]} label={gettext("Tag (English)")} />
          <.input type="text" field={@form[:tag_pl]} label={gettext("Tag (Polish)")} />
          <.input
            type="select"
            field={@form[:type]}
            label={gettext("Type")}
            prompt={gettext("Select type")}
            options={@types}
          />
          <.input
            type="text"
            field={@form[:pic_url]}
            label={gettext("Image URL")}
            placeholder="/images/West-coast-swing.webp"
          />
        </.form_modal>
      <% nil -> %>
    <% end %>
    """
  end
end
