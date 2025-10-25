defmodule WcsStudioWeb.UserSettingsLive do
  use WcsStudioWeb, :live_view

  alias WcsStudio.Accounts
  import WcsStudioWeb.Gettext

  @max_dimension 1024
  @webp_quality 85
  @qr_max_dimension 512

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, gettext("Email changed successfully."))

        :error ->
          put_flash(socket, :error, gettext("Email change link is invalid or it has expired."))
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> allow_upload(:profile_pic,
           accept: ~w(.jpg .jpeg .png .webp),
           max_entries: 1,
           max_file_size: 5_000_000, # 5MB before conversion
           auto_upload: true
         )
      |> allow_upload(:qr_code,
           accept: ~w(.jpg .jpeg .png .webp),
           max_entries: 1,
           max_file_size: 3_000_000, # 3MB for QR codes
           auto_upload: true
         )

    {:ok, socket}
  end

  def handle_event("validate_profile_pic", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("validate_qr_code", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save_profile_pic", _params, socket) do
    user = socket.assigns.current_user
    old_profile_pic_url = user.profile_pic_url

    uploaded_files =
      consume_uploaded_entries(socket, :profile_pic, fn %{path: path}, entry ->
        case validate_and_process_image(path, entry, :profile) do
          {:ok, url} -> {:ok, url}
          {:error, reason} ->
            require Logger
            Logger.error("Profile picture processing failed: #{inspect(reason)}")
            {:postpone, :error}
        end
      end)

    case uploaded_files do
      [url] when is_binary(url) ->
        case Accounts.update_user_profile_pic_url(user, url) do
          {:ok, updated_user} ->
            delete_old_profile_pic(old_profile_pic_url)

            {:noreply,
              socket
              |> put_flash(:info, gettext("Profile picture updated successfully!"))
              |> assign(:current_user, updated_user)}

          {:error, _changeset} ->
            delete_profile_pic_file(url)

            {:noreply,
              socket
              |> put_flash(:error, gettext("Failed to update profile picture in database."))}
        end

      [] ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Please select a picture before uploading."))}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Upload failed. Please ensure you're uploading a valid image file."))}
    end
  end

  def handle_event("save_qr_code", _params, socket) do
    user = socket.assigns.current_user
    old_qr_code_url = user.qr_code_url

    uploaded_files =
      consume_uploaded_entries(socket, :qr_code, fn %{path: path}, entry ->
        case validate_and_process_image(path, entry, :qr_code) do
          {:ok, url} -> {:ok, url}
          {:error, reason} ->
            require Logger
            Logger.error("QR code processing failed: #{inspect(reason)}")
            {:postpone, :error}
        end
      end)

    case uploaded_files do
      [url] when is_binary(url) ->
        case Accounts.update_user_qr_code_url(user, url) do
          {:ok, updated_user} ->
            delete_old_qr_code(old_qr_code_url)

            {:noreply,
              socket
              |> put_flash(:info, gettext("QR code updated successfully!"))
              |> assign(:current_user, updated_user)}

          {:error, _changeset} ->
            delete_profile_pic_file(url)

            {:noreply,
              socket
              |> put_flash(:error, gettext("Failed to update QR code in database."))}
        end

      [] ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Please select a QR code image before uploading."))}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, gettext("Upload failed. Please ensure you're uploading a valid image file."))}
    end
  end

  def handle_event("cancel_upload", %{"ref" => ref, "upload" => upload_type}, socket) do
    upload_atom = String.to_existing_atom(upload_type)
    {:noreply, cancel_upload(socket, upload_atom, ref)}
  end

  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    # Fallback for old cancel buttons without upload type
    {:noreply, cancel_upload(socket, :profile_pic, ref)}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = gettext("A link to confirm your email change has been sent to the new address.")
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  # Private functions for image processing

  # Helper function to validate and process the image
  defp validate_and_process_image(path, entry, type) do
    with {:ok, _validated_path} <- validate_image(path),
         {:ok, _webp_path, filename} <- convert_to_webp(path, entry, type) do
      {:ok, ~p"/uploads/#{filename}"}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_image(path) do
    # Check if it's actually an image file
    case :erl_tar.table(String.to_charlist(path)) do
      {:ok, _} -> {:error, gettext("Invalid image file")}
      {:error, _} ->
        # Not a tar file, proceed with image validation
        case File.read(path) do
          {:ok, <<0xFF, 0xD8, 0xFF, _::binary>>} -> {:ok, path} # JPEG
          {:ok, <<0x89, 0x50, 0x4E, 0x47, _::binary>>} -> {:ok, path} # PNG
          {:ok, <<"RIFF", _::binary-size(4), "WEBP", _::binary>>} -> {:ok, path} # WebP
          {:ok, _} -> {:error, gettext("Invalid image format")}
          {:error, reason} -> {:error, gettext("Could not read file: %{reason}", reason: inspect(reason))}
        end
    end
  end

  defp convert_to_webp(source_path, entry, type) do
    uploads_dir = Path.join([:code.priv_dir(:wcs_studio), "static", "uploads"])
    File.mkdir_p!(uploads_dir)

    # Generate unique filename based on type
    prefix = case type do
      :profile -> "profile"
      :qr_code -> "qr"
      _ -> "image"
    end

    filename = "#{prefix}_#{System.system_time(:millisecond)}_#{entry.uuid}.webp"
    dest_path = Path.join(uploads_dir, filename)

    # Use different max dimensions based on type
    max_dim = case type do
      :qr_code -> @qr_max_dimension
      _ -> @max_dimension
    end

    # Use Image library
    case convert_with_image(source_path, dest_path, max_dim) do
      :ok -> {:ok, dest_path, filename}
      {:error, reason} ->
        {:error, gettext("Image conversion failed: %{reason}", reason: inspect(reason))}
    end
  end

  # Using the Image library (add {:image, "~> 0.37"} to mix.exs)
  defp convert_with_image(source_path, dest_path, max_dimension) do
    try do
      case Image.open(source_path) do
        {:ok, image} ->
          # Resize if too large
          image =
            if Image.width(image) > max_dimension or Image.height(image) > max_dimension do
              {:ok, resized} = Image.thumbnail(image, max_dimension)
              resized
            else
              image
            end

          # Save as WebP
          Image.write(image, dest_path, quality: @webp_quality)
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    rescue
      _ -> {:error, :image_library_not_available}
    end
  end

  defp delete_old_profile_pic(nil), do: :ok
  defp delete_old_profile_pic(""), do: :ok
  defp delete_old_profile_pic(url) do
    delete_profile_pic_file(url)
  end

  defp delete_old_qr_code(nil), do: :ok
  defp delete_old_qr_code(""), do: :ok
  defp delete_old_qr_code(url) do
    delete_profile_pic_file(url)
  end

  defp delete_profile_pic_file(url) when is_binary(url) do
    # Extract filename from URL (e.g., "/uploads/profile_123.webp" -> "profile_123.webp")
    case Regex.run(~r/\/uploads\/(.+)$/, url) do
      [_, filename] ->
        uploads_dir = Path.join([:code.priv_dir(:wcs_studio), "static", "uploads"])
        file_path = Path.join(uploads_dir, filename)
        if File.exists?(file_path) && file_path != "/images/user_icon" do
          File.rm(file_path)
        end

      _ ->
        :ok
    end
  end

  def render(assigns) do
    ~H"""
    <div class="px-4 py-4">
      <.header class="text-center">
        <%= gettext("Account Settings") %>
        <:subtitle><%= gettext("Manage your account email address and password settings") %></:subtitle>
      </.header>

      <div class="space-y-12 divide-y">
        <div>
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label={gettext("Email")} required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label={gettext("Current password")}
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button phx-disable-with={gettext("Changing...")} class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-medium py-3 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-pink-500/25 hover:-translate-y-0.5">
                <%= gettext("Change Email") %>
              </.button>
            </:actions>
          </.simple_form>
        </div>

        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <input
              name={@password_form[:email].name}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input field={@password_form[:password]} type="password" label={gettext("New password")} required />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label={gettext("Confirm new password")}
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label={gettext("Current password")}
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button phx-disable-with={gettext("Changing...")} class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-medium py-3 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-pink-500/25 hover:-translate-y-0.5">
                <%= gettext("Change Password") %>
              </.button>
            </:actions>
          </.simple_form>
        </div>

        <div class="pt-8">
          <h3 class="text-lg font-semibold mb-4"><%= gettext("Profile Picture") %></h3>

          <%= if @current_user.profile_pic_url do %>
            <div class="mb-4">
              <img
                src={@current_user.profile_pic_url}
                alt={gettext("Current profile picture")}
                class="w-32 h-32 rounded-full object-cover border-2 border-gray-200 shadow-md"
              />
            </div>
          <% end %>

          <form phx-submit="save_profile_pic" phx-change="validate_profile_pic">
            <div class="mb-3">
              <label class="block text-sm font-medium text-white mb-2">
                <%= gettext("Upload new profile picture") %>
                <span class="text-gray-400 text-xs"><%= gettext("(JPG, PNG, or WebP • Max 5MB)") %></span>
              </label>
              <.live_file_input upload={@uploads.profile_pic} class="block w-full text-white font-medium
                file:mr-4 file:py-2 file:px-4
                file:rounded-lg file:border-0
                file:text-white file:font-semibold
                file:bg-gradient-to-r file:from-pink-500 file:to-purple-600
                hover:file:shadow-pink-500/25
                cursor-pointer"
              />
            </div>

            <%= for entry <- @uploads.profile_pic.entries do %>
              <div class="mb-3 p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <span class="text-sm font-medium text-gray-700"><%= entry.client_name %></span>
                  <button
                    type="button"
                    phx-click="cancel_upload"
                    phx-value-ref={entry.ref}
                    phx-value-upload="profile_pic"
                    class="text-red-600 hover:text-red-800 text-sm font-medium"
                  >
                    <%= gettext("Cancel") %>
                  </button>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div
                    class="bg-indigo-600 h-2 rounded-full transition-all duration-300"
                    style={"width: #{entry.progress}%"}
                  >
                  </div>
                </div>
                <span class="text-xs text-gray-500 mt-1 block"><%= gettext("%{progress}% complete", progress: entry.progress) %></span>
              </div>
            <% end %>

            <%= for err <- upload_errors(@uploads.profile_pic) do %>
              <div class="mb-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                <p class="text-red-700 text-sm font-medium"><%= error_to_string(err) %></p>
              </div>
            <% end %>

            <.button
              type="submit"
              class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-medium py-3 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-pink-500/25 hover:-translate-y-0.5"
              disabled={@uploads.profile_pic.entries == []}
            >
              <%= gettext("Change profile picture") %>
            </.button>
          </form>
        </div>

        <div class="pt-8">
          <h3 class="text-lg font-semibold mb-4"><%= gettext("QR Code") %></h3>

          <%= if @current_user.qr_code_url do %>
            <div class="mb-4">
              <img
                src={@current_user.qr_code_url}
                alt={gettext("Current QR code")}
                class="w-48 h-48 object-contain border-2 border-gray-200 shadow-md rounded-lg bg-white p-2"
              />
            </div>
          <% end %>

          <form phx-submit="save_qr_code" phx-change="validate_qr_code">
            <div class="mb-3">
              <label class="block text-sm font-medium text-white mb-2">
                <%= gettext("Upload QR code") %>
                <span class="text-gray-400 text-xs"><%= gettext("(JPG, PNG, or WebP • Max 3MB • Optimized to 512px)") %></span>
              </label>
              <.live_file_input upload={@uploads.qr_code} class="block w-full text-white font-medium
                file:mr-4 file:py-2 file:px-4
                file:rounded-lg file:border-0
                file:text-white file:font-semibold
                file:bg-gradient-to-r file:from-pink-500 file:to-purple-600
                hover:file:shadow-pink-500/25
                cursor-pointer"
              />
            </div>

            <%= for entry <- @uploads.qr_code.entries do %>
              <div class="mb-3 p-3 bg-gray-50 rounded-lg">
                <div class="flex items-center justify-between mb-2">
                  <span class="text-sm font-medium text-gray-700"><%= entry.client_name %></span>
                  <button
                    type="button"
                    phx-click="cancel_upload"
                    phx-value-ref={entry.ref}
                    phx-value-upload="qr_code"
                    class="text-red-600 hover:text-red-800 text-sm font-medium"
                  >
                    <%= gettext("Cancel") %>
                  </button>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div
                    class="bg-indigo-600 h-2 rounded-full transition-all duration-300"
                    style={"width: #{entry.progress}%"}
                  >
                  </div>
                </div>
                <span class="text-xs text-gray-500 mt-1 block"><%= gettext("%{progress}% complete", progress: entry.progress) %></span>
              </div>
            <% end %>

            <%= for err <- upload_errors(@uploads.qr_code) do %>
              <div class="mb-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                <p class="text-red-700 text-sm font-medium"><%= error_to_string(err) %></p>
              </div>
            <% end %>

            <.button
              type="submit"
              class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white font-medium py-3 px-6 rounded-lg transition-all duration-300 hover:shadow-lg hover:shadow-pink-500/25 hover:-translate-y-0.5"
              disabled={@uploads.qr_code.entries == []}
            >
              <%= gettext("Upload QR Code") %>
            </.button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: gettext("File is too large (max 5MB for profile pictures, 3MB for QR codes)")
  defp error_to_string(:not_accepted), do: gettext("File type not accepted (use .jpg, .jpeg, .png, or .webp)")
  defp error_to_string(:too_many_files), do: gettext("Too many files (max 1)")
  defp error_to_string(_), do: gettext("Unknown error")
end