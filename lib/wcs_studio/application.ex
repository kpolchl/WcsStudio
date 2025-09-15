defmodule WcsStudio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WcsStudioWeb.Telemetry,
      WcsStudio.Repo,
      {DNSCluster, query: Application.get_env(:wcs_studio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WcsStudio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WcsStudio.Finch},
      # Start a worker by calling: WcsStudio.Worker.start_link(arg)
      # {WcsStudio.Worker, arg},
      # Start to serve requests, typically the last entry
      WcsStudioWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WcsStudio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WcsStudioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
