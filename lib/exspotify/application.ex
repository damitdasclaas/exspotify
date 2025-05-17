defmodule Exspotify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    unless Mix.env == :prod do
      Dotenv.load
      Mix.Task.run("loadconfig")
    end

    children = [
      # Starts a worker by calling: Exspotify.Worker.start_link(arg)
      # {Exspotify.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exspotify.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
