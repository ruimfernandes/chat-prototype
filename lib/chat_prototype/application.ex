defmodule ChatPrototype.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatPrototypeWeb.Telemetry,
      ChatPrototype.Repo,
      {DNSCluster, query: Application.get_env(:chat_prototype, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChatPrototype.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ChatPrototype.Finch},
      # Start a worker by calling: ChatPrototype.Worker.start_link(arg)
      # {ChatPrototype.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatPrototypeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatPrototype.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatPrototypeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
