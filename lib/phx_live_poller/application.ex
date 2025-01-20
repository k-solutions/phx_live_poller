defmodule PhxLivePoller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhxLivePollerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phx_live_poller, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhxLivePoller.PubSub},
      # Start the Finch HTTP client for sending emails
      # {Finch, name: PhxLivePoller.Finch},
      # User acccounts storage and API
      {PhxLivePoller.Accounts, {}},
      # Poller Storage and API  
      {PhxLivePoller.Polls, {}},
      # Start to serve requests, typically the last entry
      PhxLivePollerWeb.Endpoint,
      PhxLivePoller.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxLivePoller.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhxLivePollerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
