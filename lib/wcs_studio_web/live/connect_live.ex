defmodule WcsStudioWeb.ConnectLive do
  use WcsStudioWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div class="max-w-5xl mx-auto px-4 py-16">
        <!-- About Me Section -->
        <section class="mb-20">
          <div class="bg-slate-800/30 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-8 md:p-12">
            <div class="flex flex-col md:flex-row gap-8 items-center mb-8">
              <div class="w-40 h-40 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500 p-1 flex-shrink-0">
                <img
                  src="/images/profile.jpg"
                  alt=" "
                  class="w-full h-full rounded-2xl object-cover"

                >
              </div>
              <div>
                <h1 class="text-4xl md:text-5xl font-bold text-white mb-2">
                  <%= gettext("Hey, I'm") %> <span class="text-transparent bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text">Karol Półchłopek</span>
                </h1>
                <p class="text-xl text-slate-300">Full Stack Developer</p>
              </div>
            </div>

            <div class="space-y-4 text-slate-300 leading-relaxed text-lg">
              <p>
                <%= gettext("Welcome to my corner of the internet! I'm a passionate developer who loves building
                web applications. This one was build with") %> <span class="text-purple-400 font-semibold">Elixir</span> <%= gettext("and") %>
                <span class="text-pink-400 font-semibold">Phoenix LiveView</span>.
              </p>
              <p>
                <%= gettext("When I'm not coding, you'll see me dancing.") %>
              </p>
            </div>


          </div>
        </section>

        <!-- Contact Section -->
        <section>
          <div class="bg-slate-800/30 backdrop-blur-sm rounded-2xl border border-slate-700/50 p-8 md:p-12">
            <h2 class="text-3xl font-bold text-white mb-6">
              <i class="fas fa-paper-plane text-purple-400 mr-3"></i>
              <%= gettext("Get In Touch") %>
            </h2>
            <p class="text-slate-300 text-lg mb-8">
              <%= gettext("Have a project in mind or just want to say hello? I'd love to hear from you!") %>
            </p>

            <div class="grid md:grid-cols-2 gap-8">
              <!-- Contact Info -->
              <div class="space-y-6">
                <div class="flex items-center gap-4 text-slate-300">
                  <div class="w-12 h-12 rounded-lg bg-purple-500/20 flex items-center justify-center text-purple-400">
                    <i class="fas fa-envelope text-xl"></i>
                  </div>
                  <div>
                    <p class="text-sm text-slate-400">Email</p>
                    <a href="mailto:karol.szarooki@gmail.com" class="text-white hover:text-purple-400 transition-colors">
                      karol.szarooki@gmail.com
                    </a>
                  </div>
                </div>

                <div class="flex items-center gap-4 text-slate-300">
                  <div class="w-12 h-12 rounded-lg bg-pink-500/20 flex items-center justify-center text-pink-400">
                    <i class="fab fa-github text-xl"></i>
                  </div>
                  <div>
                    <p class="text-sm text-slate-400">GitHub</p>
                    <a href="https://github.com/kpolchl" target="_blank" class="text-white hover:text-pink-400 transition-colors">
                      @kpolchl
                    </a>
                  </div>
                </div>

                <div class="flex items-center gap-4 text-slate-300">
                  <div class="w-12 h-12 rounded-lg bg-green-500/20 flex items-center justify-center text-green-400">
                    <i class="fab fa-linkedin text-xl"></i>
                  </div>
                  <div>
                    <p class="text-sm text-slate-400">LinkedIn</p>
                    <a href="https://www.linkedin.com/in/karol-p%C3%B3%C5%82ch%C5%82opek-092803357/" target="_blank" class="text-white hover:text-green-400 transition-colors">
                      in/karol-półchłopek
                    </a>
                  </div>
                </div>
              </div>

              <!-- Contact Form -->
              <div>
                <form phx-submit="send_message" class="space-y-4">
                  <div>
                    <label class="block text-slate-300 font-medium mb-2">Name</label>
                    <input
                      type="text"
                      name="name"
                      required
                      class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      placeholder={gettext("Your name")}
                    >
                  </div>

                  <div>
                    <label class="block text-slate-300 font-medium mb-2">Email</label>
                    <input
                      type="email"
                      name="email"
                      required
                      class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      placeholder={gettext("your@email.com")}
                    >
                  </div>

                  <div>
                    <label class="block text-slate-300 font-medium mb-2">Message</label>
                    <textarea
                      name="message"
                      rows="4"
                      required
                      class="w-full px-4 py-3 bg-slate-900/50 border border-slate-600 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent transition-all"
                      placeholder={gettext("Tell me about your project...")}
                    ></textarea>
                  </div>

                  <button 
                    type="submit"
                    class="w-full px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white font-medium rounded-xl hover:shadow-lg hover:shadow-purple-500/50 transition-all duration-300"
                  >
                    <i class="fas fa-paper-plane mr-2"></i>
                    <%= gettext("Send Message") %>
                  </button>
                </form>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_message", %{"name" => name, "email" => email, "message" => message}, socket) do
    case deliver_contact_message(name, email, message) do
      {:ok, _} ->
        Logger.info("Contact form message sent from #{email}")

        {:noreply,
          socket
          |> put_flash(:info, "Thanks for reaching out! I'll get back to you soon.")
          |> push_navigate(to: ~p"/connect")}

      {:error, reason} ->
        Logger.error("Failed to send contact form email: #{inspect(reason)}")

        {:noreply,
          socket
          |> put_flash(:error, "Sorry, there was an error sending your message. Please email me directly at karol.szarooki@gmail.com")
          |> push_navigate(to: ~p"/connect")}
    end
  end

  defp deliver_contact_message(name, email, message) do
    import Swoosh.Email

    new()
    |> to({"Karol Półchłopek", "karol.szarooki@gmail.com"})
    |> from({"WcsStudio Contact Form", "noreply@wcsstudio.nextserwewusek.top"})
    |> reply_to(email)
    |> subject("💬 New message from #{name}")
    |> html_body("""
    <div style="font-family: system-ui, -apple-system, sans-serif; max-width: 600px; margin: 0 auto;">
      <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0; font-size: 24px;">New Contact Form Message</h1>
      </div>

      <div style="background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px;">
        <div style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
          <p style="margin: 0 0 10px 0; color: #6b7280;"><strong>From:</strong></p>
          <p style="margin: 0; color: #111827; font-size: 16px;">#{name}</p>
        </div>

        <div style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
          <p style="margin: 0 0 10px 0; color: #6b7280;"><strong>Email:</strong></p>
          <p style="margin: 0; color: #111827; font-size: 16px;">
            <a href="mailto:#{email}" style="color: #667eea; text-decoration: none;">#{email}</a>
          </p>
        </div>

        <div style="background: white; padding: 20px; border-radius: 8px;">
          <p style="margin: 0 0 10px 0; color: #6b7280;"><strong>Message:</strong></p>
          <p style="margin: 0; color: #111827; font-size: 16px; line-height: 1.6; white-space: pre-wrap;">#{message}</p>
        </div>

        <div style="margin-top: 20px; padding: 15px; background: #e0e7ff; border-radius: 8px; text-align: center;">
          <p style="margin: 0; color: #4338ca; font-size: 14px;">
            💡 <strong>Tip:</strong> Click "Reply" to respond directly to #{name}
          </p>
        </div>
      </div>
    </div>
    """)
    |> text_body("""
    New Contact Form Message

    From: #{name}
    Email: #{email}

    Message:
    #{message}

    ---
    Reply to this email to respond directly to the sender.
    """)
    |> WcsStudio.Mailer.deliver()
  end
end