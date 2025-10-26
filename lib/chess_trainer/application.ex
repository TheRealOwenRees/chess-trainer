defmodule ChessTrainer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChessTrainerWeb.Telemetry,
      ChessTrainer.Repo,
      {DNSCluster, query: Application.get_env(:chess_trainer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ChessTrainer.PubSub},
      # Start a worker by calling: ChessTrainer.Worker.start_link(arg)
      # {ChessTrainer.Worker, arg},
      # Start to serve requests, typically the last entry
      ChessTrainerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChessTrainer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChessTrainerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
