defmodule Exspotify.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    unless Mix.env == :prod do
      Dotenv.load
      Mix.Task.run("loadconfig")
    end

    # Validate configuration if debug mode is enabled
    if Application.get_env(:exspotify, :debug, false) do
      validate_configuration()
    end

    children = [
      # Starts a worker by calling: Exspotify.Worker.start_link(arg)
      # {Exspotify.Worker, arg}
      {Exspotify.TokenManager, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exspotify.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Validates Exspotify configuration and logs warnings for missing config
  defp validate_configuration do
    required_for_client_credentials = [:client_id, :client_secret]
    optional_for_user_auth = [:redirect_uri]

    missing_required = Enum.filter(required_for_client_credentials, fn key ->
      is_nil(Application.get_env(:exspotify, key)) || Application.get_env(:exspotify, key) == ""
    end)

    if not Enum.empty?(missing_required) do
      Logger.warning("Exspotify Configuration: Missing required config #{inspect(missing_required)}. " <>
                  "Client credentials flow will not work without these. " <>
                  "Add them to your config.exs: config :exspotify, client_id: \"...\", client_secret: \"...\"")
    end

    missing_optional = Enum.filter(optional_for_user_auth, fn key ->
      is_nil(Application.get_env(:exspotify, key)) || Application.get_env(:exspotify, key) == ""
    end)

    if not Enum.empty?(missing_optional) do
      Logger.info("Exspotify Configuration: Missing optional config #{inspect(missing_optional)}. " <>
                  "User authorization flows will require redirect_uri.")
    end

    Logger.debug("Exspotify Configuration validated successfully")
  end
end
