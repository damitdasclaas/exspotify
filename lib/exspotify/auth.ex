defmodule Exspotify.Auth do
  alias Finch
  alias Exspotify.Finch, as: FinchInstance # Assuming Finch is configured with this name

  defp config, do: Application.get_all_env(:exspotify)

  def get_access_token do
    client_id = Keyword.get(config(), :client_id)
    client_secret = Keyword.get(config(), :client_secret)

    auth_string = Base.encode64("#{client_id}:#{client_secret}")

    body = URI.encode_query(%{"grant_type" => "client_credentials"})

    request = Finch.build(
      :post,
      "https://accounts.spotify.com/api/token",
      [{"Authorization", "Basic #{auth_string}"}, {"Content-Type", "application/x-www-form-urlencoded"}],
      body
    )

    case Finch.request(request, FinchInstance) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"access_token" => _token} = decoded_body} -> {:ok, decoded_body} # Store and return the token
          {:error, reason} -> {:error, "Failed to parse token response: #{reason}"}
        end
      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, "Failed to get access token: Status #{status}, Body: #{body}"}
      {:error, reason} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  # ... other auth functions for different flows, token refresh, etc.
end
