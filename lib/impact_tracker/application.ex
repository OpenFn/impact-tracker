defmodule ImpactTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ImpactTrackerWeb.Telemetry,
      ImpactTracker.Repo,
      {DNSCluster,
       query: Application.get_env(:impact_tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ImpactTracker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ImpactTracker.Finch},
      # Start a worker by calling: ImpactTracker.Worker.start_link(arg)
      # {ImpactTracker.Worker, arg},
      {Oban, Application.fetch_env!(:impact_tracker, Oban)},
      # Start to serve requests, typically the last entry
      ImpactTrackerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ImpactTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ImpactTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
